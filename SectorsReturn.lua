local appManifestINI = ac.INIConfig.load("manifest.ini")
local appVersion = string.gsub(appManifestINI:get("ABOUT", "VERSION ", "0.0"), "%s+", "")

local SIM = ac.getSim()
local CAR = ac.getCar(0)
local TRACK = ac.getTrackID()
local SESSION = ac.getSession(0)
local sectorRecordOK, SectorRecord = pcall(require, 'SectorRecord')
if not sectorRecordOK then SectorRecord = nil end
local resetGhostPlayback

local returnButton = ac.ControlButton('__APP_SECTORSPRACTICE_RETURN')
local saveReturnButton = ac.ControlButton('__APP_SECTORSPRACTICE_SAVE')

local app = {
        title = "Sectors Practice v"..appVersion,
        settings_path = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\_settings.json",
        font = ui.DWriteFont("Roboto:/assets/fonts/Roboto-Medium.ttf;Weight=Regular"),
        delta = 0,
	uiDecay = 110, -- Espacio horizontal entre columnas de sectores
	prevSectorTime = 0,
	currentSector = 1,
        allowedTyresOut = SIM.allowedTyresOut,
        isOnline = CAR.sessionID ~= -1 and true or false,
        currentSectorTimer = 0,
        currentSectorStartClock = nil,
        lastSectorForTimer = nil,
        liveStartClock = nil,
        liveSector = nil,
        teleportCooldownUntil = nil,
        colors = {
		RED			= rgbm(1, 0.15, 0, 1),
		ORANGE		= rgbm(1, 0.55, 0, 1),
		WHITE		= rgbm(1, 1, 1, 1),
		YELLOW		= rgbm(1, 0.85, 0, 1),
		DARK_GREY   = rgbm(0.09, 0.09, 0.09, 1),
		MID_GREY    = rgbm(0.25, 0.25, 0.25, 1),
		GREY		= rgbm(0.6, 0.6, 0.6, 1),
		PURPLE		= rgbm(1, 0.25, 1, 1),
		GREEN       = rgbm(0, 1, 0, 1),
		CYAN        = rgbm(0, 1, 1, 1)
	},
        userData = {
                data = {},
                settings = {
                        savepb = false,
                        allowedTyresOut = 3,
                        showGhost = false,
                        showGhostLine = false,
                        showGhostCar = false,
                },
        },
        ghostSectors = {},
        ghostInputs = {},
        ghostColor = rgbm(0.8, 0.4, 1, 0.7),
        ghostSectorDuration = {},
        ghostSectorTimeline = {},
        ghostPlayback = { active = false, sector = nil, timeMs = 0, totalMs = 0 },
        currentRunMeasure = {},
        currentRunStartState = {},
        currentRunSector = nil,
        sNotif = '',
    -- Variables para Dynamic Return
    sectorStates = {},
    returnStates = {},
    teleporting = false,
    lastFrameSector = 1,
    sessionLastLapMs = 0,
    sessionBestLapMs = 0,
    lastReturnSector = 1
}


--- Obtener puntos de inicio de sectores
app.getTrackSectors = function()
	local splits = SIM.lapSplits
	if splits[0] ~= nil then
		local ret = {}
		for i=0, #splits do
			ret[#ret+1] = splits[i]
		end
		return ret
	end
	return {0.00000001, 0.33, 0.66} -- Valores por defecto si falla
end

local appData = {
        prevLapCount = -1,
        sector_count = #app.getTrackSectors(),
        sectors = app.getTrackSectors(),
        current_sectors = {},
        sectorsValid = {},
        sectorsdata = {
                best = {},
                target = {},
                microBest = {},
        },
        mSectorsLast = {},
        pb = false
}

--- Inicializar micro sectores
app.set_microSectors = function()
        appData.mSectors = {}
        appData.mSectorsisBest = {}
        appData.mSectorsLast = {}
        for i=1, appData.sector_count do
                appData.mSectors[i] = {}
                appData.mSectorsisBest[i] = {}
                for j=1, 8 do
                        appData.mSectors[i][j] = 0
                        appData.mSectorsisBest[i][j] = 0
                        appData.mSectorsLast[i] = appData.mSectorsLast[i] or {}
                        appData.mSectorsLast[i][j] = 0
                end
        end

	appData.mSectorsCheck = {
		current = 1,
		isValid = true,
		startTime = 0
	}
end

local function copyCurrentMicroToLast(sectorIndex)
        if not sectorIndex then return end
        appData.mSectorsLast[sectorIndex] = appData.mSectorsLast[sectorIndex] or {}
        for j=1, 8 do
                appData.mSectorsLast[sectorIndex][j] = appData.mSectors[sectorIndex][j] or 0
        end
end

--- Obtener sector actual basado en posición spline
app.getCurrentSector = function()
        for i=1, appData.sector_count do
		if CAR.splinePosition >= appData.sectors[i] and CAR.splinePosition < (i < appData.sector_count and appData.sectors[i+1] or 1) then
			return i
		end
	end
	return 1
end

--- Formatear tiempo
app.time_to_string = function(time_s)
	if time_s == nil or time_s == 0 then return "--.---" end
	local minutes = math.floor(time_s / 60)
	time_s = time_s - minutes * 60
	if minutes > 0 then
		out = string.format("%d:%06.3f", minutes, time_s)
	else
		out = string.format("%06.3f", time_s)
	end
	return out
end


-- ================= SECCIÓN DE SETTINGS Y DATOS =================


app.saveCarData = function(carId)
        if not carId then carId = ac.getCarID() end
        local filePath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\"..carId..".json"
        app.userData.data[TRACK] = appData.sectorsdata
        local carJson = JSON.stringify(app.userData.data, {pretty=true})
	io.saveAsync(filePath, carJson)
end

app.loadCarData = function(carId)
	if not carId then carId = ac.getCarID() end
	local filePath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\"..carId..".json"
	if io.exists(filePath) then
		local data = io.load(filePath)
		local carJson = JSON.parse(data)
		app.userData.data = carJson
		local sectorsdata = carJson[TRACK]
		if sectorsdata then
			appData.sectorsdata = sectorsdata
		end
        else
                app.userData.data[TRACK] = { best = {}, target = {}, microBest = {} }
        end
end

app.checkOldSettings = function()
	local oldSettingsPath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\sectors.json"
	if io.exists(oldSettingsPath) then
		local data = io.load(oldSettingsPath)
		local json_full = JSON.parse(data)
		if json_full['data'] ~= nil then
			for carId, data in pairs(json_full['data']) do
				local filePath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\"..carId..".json"
				io.saveAsync(filePath, JSON.stringify(data, {pretty=true}))
			end
		end
		app.userData.settings = json_full.settings
		if json_full['data'][ac.getCarID()][TRACK] ~= nil then
			appData.sectorsdata = json_full['data'][ac.getCarID()][TRACK]
		else
			appData.sectorsdata = { best = {}, target = {} }
		end
		app.saveSettings()
		io.recycle(oldSettingsPath)
	end
end

app.saveSettings = function(async)
        async = async or false
        local jsonSettings = JSON.stringify(app.userData.settings, {pretty=true})
        if async then io.saveAsync(app.settings_path, jsonSettings) else io.save(app.settings_path, jsonSettings) end
end

app.loadSettings = function()
	local appPath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\"
	if not io.exists(appPath) then io.createDir(appPath) end

        if io.exists(app.settings_path) then
                local data = io.load(app.settings_path)
                local json_full = JSON.parse(data)
                if json_full ~= nil then
                        local doSave = false
                        if json_full.showGhostLine == nil and json_full.showGhost ~= nil then
                                json_full.showGhostLine = json_full.showGhost
                                json_full.showGhostCar = json_full.showGhost
                                doSave = true
                        end

                        if json_full.showGhostLine == nil and json_full.showGhostCar == nil then
                                json_full.showGhostLine = false
                                json_full.showGhostCar = false
                                doSave = true
                        end

                        for key, value in pairs(app.userData.settings) do
                                if json_full[key] == nil then
                                        json_full[key] = app.userData.settings[key]
                                        doSave = true
                                end
			end
			app.userData.settings = json_full
			if doSave then app.saveSettings() end
		end
	end
end

app.loadPersonalBest = function()
	local sect = string.upper(ac.getCarID(0).."@"..TRACK.."-"..ac.getTrackLayout())
	local fullpath = ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/personalbest.ini"
	local pb = ac.INIConfig.load(fullpath, ac.INIFormat.Extended):get(sect, "TIME", -1)
	if pb ~= nil and pb > 0 then appData.pb = pb else appData.pb = math.huge end
end

app.savePersonalBest = function(lapTimeMs)
	appData.pb = lapTimeMs
	local sect = string.upper(ac.getCarID(0).."@"..TRACK.."-"..ac.getTrackLayout())
	local fullpath = ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/personalbest.ini"
	local nowTimestamp = os.time(os.date('*t'))
	local data = ac.INIConfig.load(fullpath, ac.INIFormat.Extended)
	data:set(sect, "TIME", lapTimeMs)
	data:set(sect, "DATE", nowTimestamp)
	data:save(fullpath, ac.INIFormat.Extended)
end

app.init = function()
        app.checkOldSettings()
        app.loadSettings()
        app.loadCarData()
        appData.sectorsdata.microBest = appData.sectorsdata.microBest or {}
        for i=1, appData.sector_count do
                appData.current_sectors[i] = 0
                appData.sectorsdata.best[i] = appData.sectorsdata.best[i] or 0
                appData.sectorsdata.target[i] = appData.sectorsdata.target[i] or 0
                appData.sectorsdata.microBest[i] = appData.sectorsdata.microBest[i] or {}
                appData.mSectorsLast[i] = appData.mSectorsLast[i] or {}
                appData.sectorsValid[i] = true
        end
    app.loadPersonalBest()
    app.set_microSectors()
    if SIM.allowedTyresOut > -1 then app.allowedTyresOut = app.userData.settings.allowedTyresOut end
    app.returnStates = {}
    app.lastReturnSector = 1
    app.loadSectorStates()   -- NUEVO: cargar states guardados para este auto+pista
    app.loadSectorGhosts()

    app.sessionLastLapMs = 0
    app.sessionBestLapMs = 0
    app.currentSectorValid = true
    app.currentRunMeasure = {}
    app.currentRunStartState = {}

    app.currentSectorStartClock = nil
    app.currentSectorTimer = 0
    app.lastSectorForTimer = app.getCurrentSector()
    app.liveStartClock = nil
    app.liveSector = nil
    app.teleportCooldownUntil = nil
    app.lastFrameSector = app.getCurrentSector()
    app.prevSectorTime = CAR.previousSectorTime or 0
    resetGhostPlayback()

end

-- ================= GUARDADO DE STATES DE RETURN =================

-- Ruta única por auto + pista + layout + sector
local function getSectorStatePath(sectorIndex, carId)
    if not carId then carId = ac.getCarID() end
    local basePath = ac.getFolder(ac.FolderID.ACDocuments).."\\apps\\SectorsReturn\\"
    local layout = ac.getTrackLayout()
    -- Ejemplo: returnState_ks_audi_r8_lms_nurburgring-gp_S1.lon
    return string.format("%sreturnState_%s_%s-%s_S%d.lon",
        basePath, carId, TRACK, layout, sectorIndex)
end

app.loadSectorStates = function(carId)
    app.sectorStates = {}
    for i = 1, appData.sector_count do
        local filePath = getSectorStatePath(i, carId)
        if io.exists(filePath) then
            local ok, content = pcall(io.load, filePath)
            if ok and content then
                app.sectorStates[i] = content
            end
        end
    end
end

local function getGhostDir()
    local baseDir = ac.getFolder(ac.FolderID.ACDocuments) .. "\\apps\\SectorsReturn\\ghosts"
    return string.format("%s\\%s_%s", baseDir, ac.getTrackFullID('_'), ac.getCarID())
end

local function ensureGhostDir()
    local dir = getGhostDir()
    local baseDir = ac.getFolder(ac.FolderID.ACDocuments) .. "\\apps\\SectorsReturn\\ghosts"
    if not io.exists(baseDir) then
        pcall(io.createDir, baseDir)
    end
    if not io.exists(dir) then
        pcall(io.createDir, dir)
    end
    return dir
end

local function getSectorIndexForProgress(progress)
    if progress == nil then return nil end
    for i = 1, appData.sector_count do
        local startPos = appData.sectors[i]
        local endPos = appData.sectors[i + 1] or 1
        local p = progress
        if endPos < startPos then
            if p < startPos then p = p + 1 end
            endPos = endPos + 1
        end
        if p >= startPos and p <= endPos then
            return i
        end
    end
    return nil
end

local function parseMeasureEntry(entry)
    if type(entry) ~= 'table' then return nil end
    local pos = entry[1] or entry.pos or entry.spline or entry.progress
    local time = entry[2] or entry.time
    local gas = entry.gas or entry[3]
    local brake = entry.brake or entry[4]
    if pos == nil or time == nil then return nil end
    return {pos = pos, time = time, gas = gas, brake = brake}
end

local function buildInterpolatedGhost(measure)
    if type(measure) ~= 'table' then return {}, {} end

    local cleaned = {}
    for _, v in ipairs(measure) do
        local parsed = parseMeasureEntry(v)
        if parsed then cleaned[#cleaned + 1] = parsed end
    end
    table.sort(cleaned, function(a, b) return a.time < b.time end)
    if #cleaned < 2 then return {}, {} end

    local function lerpOptional(a, b, k)
        if a == nil and b == nil then return nil end
        if a == nil then return b end
        if b == nil then return a end
        return a + (b - a) * k
    end

    local points = {}
    local inputs = {}
    local stepMs = 50
    local totalTime = cleaned[#cleaned].time
    local idx = 1
    for t = 0, totalTime, stepMs do
        while idx < #cleaned and cleaned[idx + 1].time < t do
            idx = idx + 1
        end
        local a = cleaned[idx]
        local b = cleaned[math.min(idx + 1, #cleaned)]
        local span = b.time - a.time
        if span <= 0 then span = 1 end
        local k = (t - a.time) / span
        if k < 0 then k = 0 end
        if k > 1 then k = 1 end
        local pos = a.pos + (b.pos - a.pos) * k
        local worldPos = ac.trackProgressToWorldCoordinate(pos % 1)
        points[#points + 1] = worldPos
        inputs[#inputs + 1] = {
            gas = lerpOptional(a.gas, b.gas, k),
            brake = lerpOptional(a.brake, b.brake, k)
        }
    end

    points[#points + 1] = ac.trackProgressToWorldCoordinate(cleaned[#cleaned].pos % 1)
    inputs[#inputs + 1] = { gas = cleaned[#cleaned].gas, brake = cleaned[#cleaned].brake }
    return points, inputs
end

local function getMeasureDurationMs(measure)
    if type(measure) ~= 'table' then return 0 end
    local duration = 0
    for _, v in ipairs(measure) do
        local parsed = parseMeasureEntry(v)
        if parsed and parsed.time and parsed.time > duration then
            duration = parsed.time
        end
    end
    return duration
end

local function buildGhostTimeline(measure, startPos, endPos)
    if type(measure) ~= 'table' or not startPos or not endPos then return nil end

    local parsed = {}
    for _, v in ipairs(measure) do
        local entry = parseMeasureEntry(v)
        if entry and entry.pos ~= nil and entry.time ~= nil then
            parsed[#parsed + 1] = { pos = entry.pos, time = entry.time }
        end
    end

    if #parsed < 2 then return nil end

    table.sort(parsed, function(a, b) return (a.time or 0) < (b.time or 0) end)

    local timeline = {}
    local wrap = endPos < startPos
    local lastPos = nil
    for _, p in ipairs(parsed) do
        local pos = p.pos
        if wrap and pos < startPos then pos = pos + 1 end
        if lastPos and pos < lastPos then
            while pos < lastPos do pos = pos + 1 end
        end
        timeline[#timeline + 1] = { pos = pos, time = p.time }
        lastPos = pos
    end

    return timeline
end

local function ghostTimeAtCurrentPos(sectorIndex)
    if not sectorIndex then return nil end

    local startPos = appData.sectors[sectorIndex]
    local endPos = appData.sectors[sectorIndex + 1] or 1
    if not startPos or not endPos then return nil end

    local timeline = app.ghostSectorTimeline and app.ghostSectorTimeline[sectorIndex]
    if not timeline or #timeline < 2 then return nil end

    local spl = CAR.splinePosition
    if endPos < startPos then
        if spl < startPos then spl = spl + 1 end
        endPos = endPos + 1
    end

    local targetPos = spl
    if targetPos <= timeline[1].pos then return timeline[1].time / 1000 end

    for i = 1, #timeline - 1 do
        local a = timeline[i]
        local b = timeline[i + 1]
        if targetPos >= a.pos and targetPos <= b.pos then
            local span = b.pos - a.pos
            local k = span > 0 and (targetPos - a.pos) / span or 0
            return (a.time + (b.time - a.time) * k) / 1000
        end
    end

    return timeline[#timeline].time / 1000
end

local function getGhostPositionAtTime(sectorIndex, timeMs)
    local ghost = app.ghostSectors[sectorIndex]
    if not ghost or #ghost < 2 then return nil end

    local totalMs = app.ghostPlayback and app.ghostPlayback.totalMs or 0
    if (not totalMs or totalMs <= 0) and app.ghostSectorDuration then
        totalMs = app.ghostSectorDuration[sectorIndex] or 0
    end
    if not totalMs or totalMs <= 0 then return nil end

    local t = math.min(math.max(timeMs / totalMs, 0), 1)

    local maxIndex = #ghost - 1
    local fIndex = t * maxIndex
    local i = math.floor(fIndex) + 1
    local frac = fIndex - math.floor(fIndex)

    local p1 = ghost[i]
    local p2 = ghost[math.min(i + 1, #ghost)]
    return p1 + (p2 - p1) * frac
end

local function drawGhostCar(pos, nextPos, color)
    if not pos or not nextPos then return end

    pos = pos + vec3(0, 0.4, 0)
    nextPos = nextPos + vec3(0, 0.4, 0)

    local forward = nextPos - pos
    local forwardLen = forward:length()
    if not forwardLen or forwardLen < 0.05 then return end
    forward = forward / forwardLen

    local up = vec3(0, 1, 0)
    local right = forward:cross(up)
    local rightLen = right:length()
    if not rightLen or rightLen < 0.01 then
        right = vec3(1, 0, 0)
    else
        right = right / rightLen
    end

    local arrowColor = rgbm(0.1, 1.0, 0.1, 1.0)
    local arrowLength = 3.2
    local baseOffset = 1.2
    local halfWidth = 1.2

    local tip = pos + forward * arrowLength
    local baseCenter = pos - forward * baseOffset
    local left = baseCenter + right * halfWidth
    local rightPt = baseCenter - right * halfWidth

    render.debugLine(left, tip, arrowColor, arrowColor)
    render.debugLine(rightPt, tip, arrowColor, arrowColor)
    render.debugLine(left, rightPt, arrowColor, arrowColor)
    render.debugLine(pos, tip, arrowColor, arrowColor)
end

local function getGhostSegmentColor(input)
    if not input then return app.ghostColor or rgbm(0, 1, 0, 0.8) end

    local brake = tonumber(input.brake) or 0
    local gas = tonumber(input.gas) or 0
    local alpha = 0.9

    if brake > 0.05 then
        local intensity = math.min(math.max(brake, 0), 1)
        return rgbm(0.2 + 0.8 * intensity, 0, 0, alpha)
    end

    if gas > 0.05 then
        local intensity = math.min(math.max(gas, 0), 1)
        return rgbm(0, 0.5 + 0.5 * intensity, 0, alpha)
    end

    return rgbm(0.6, 0.6, 0.2, alpha)
end

function resetGhostPlayback()
    app.ghostPlayback.active = false
    app.ghostPlayback.sector = nil
    app.ghostPlayback.timeMs = 0
    app.ghostPlayback.totalMs = 0
end

app.loadSectorGhosts = function()
    app.ghostSectors = {}
    app.ghostInputs = {}
    app.ghostSectorDuration = {}
    app.ghostSectorTimeline = {}
    local dir = ensureGhostDir()
    if not dir or not io.exists(dir) then return end

    local ok, files = pcall(io.scanDir, dir, 'ghost_*.json')
    if not ok or not files then return end

    for _, file in ipairs(files) do
        local sectorIndex = tonumber(string.match(file, '^ghost_(%d+)%.json$'))
        if sectorIndex then
            local okLoad, content = pcall(io.load, string.format('%s\\%s', dir, file))
            if okLoad and content then
                local okJson, data = pcall(JSON.parse, content)
                if okJson and type(data) == 'table' and type(data.measure) == 'table' then
                    local measure = data.measure
                    local ghostPoints, ghostInputs = buildInterpolatedGhost(measure)
                    if #ghostPoints > 1 then
                        local durationMs = tonumber(data.durationMs) or getMeasureDurationMs(measure)
                        local startPos = appData.sectors[sectorIndex]
                        local endPos = appData.sectors[sectorIndex + 1] or 1
                        local timeline = buildGhostTimeline(measure, startPos, endPos)
                        if (not durationMs or durationMs <= 0) and timeline and #timeline > 0 then
                            durationMs = timeline[#timeline].time
                        end
                        app.ghostSectors[sectorIndex] = ghostPoints
                        app.ghostInputs[sectorIndex] = ghostInputs
                        app.ghostSectorDuration[sectorIndex] = durationMs
                        app.ghostSectorTimeline[sectorIndex] = timeline
                    end
                end
            end
        end
    end
end

local function saveSectorGhost(sectorIndex, sectorTimeSec)
    if not sectorIndex or not sectorTimeSec or sectorTimeSec <= 0 then return end

    local measure = app.currentRunMeasure[sectorIndex]
    local startState = app.currentRunStartState[sectorIndex]
    if not measure or #measure < 2 then return end

    local totalMs = math.floor(sectorTimeSec * 1000 + 0.5)
    if totalMs <= 0 then return end

    local startingPoint = appData.sectors[sectorIndex]
    local finishingPoint = appData.sectors[sectorIndex + 1] or 1

    local measureSorted = {}
    for _, v in ipairs(measure) do
        local parsed = parseMeasureEntry(v)
        if parsed then
            measureSorted[#measureSorted + 1] = {parsed.pos, parsed.time, parsed.gas or 0, parsed.brake or 0}
        end
    end
    table.sort(measureSorted, function(a, b) return (a[2] or 0) < (b[2] or 0) end)
    if #measureSorted == 0 then return end

    local lastEntry = measureSorted[#measureSorted]
    local lastTime = lastEntry[2] or 0
    if totalMs > lastTime or (lastEntry[1] ~= finishingPoint) then
        measureSorted[#measureSorted + 1] = {finishingPoint, totalMs, lastEntry[3] or 0, lastEntry[4] or 0}
    end

    local ghostPoints, ghostInputs = buildInterpolatedGhost(measureSorted)
    if #ghostPoints > 1 then
        app.ghostSectors[sectorIndex] = ghostPoints
        app.ghostInputs[sectorIndex] = ghostInputs
        app.ghostSectorDuration[sectorIndex] = totalMs
        local timeline = buildGhostTimeline(measureSorted, startingPoint, finishingPoint)
        app.ghostSectorTimeline[sectorIndex] = timeline
    end

    if not startState then
        local okState, currentState = pcall(ac.saveCarState)
        if okState and currentState then
            startState = currentState
            app.currentRunStartState[sectorIndex] = app.currentRunStartState[sectorIndex] or currentState
        end
    end

    local dir = ensureGhostDir()
    if dir then
        local ghostData = {
            startingPoint = startingPoint,
            finishingPoint = finishingPoint,
            durationMs = totalMs,
            measure = measureSorted
        }

        local okJson, jsonData = pcall(JSON.stringify, ghostData, {pretty = true})
        if okJson and jsonData then
            pcall(io.saveAsync, string.format('%s\\ghost_%d.json', dir, sectorIndex), jsonData)
        end
    end

    if SectorRecord and startState and dir and io.exists(dir) then
        local recordOk, record = pcall(SectorRecord, string.format('%s\\ghost_S%d.lon', dir, sectorIndex), startState, startingPoint, finishingPoint)
        if recordOk and record then
            pcall(function()
                return record:register(totalMs, measureSorted)
            end)
            if #ghostPoints > 1 then
                app.ghostSectors[sectorIndex] = ghostPoints
                app.ghostInputs[sectorIndex] = ghostInputs
            end
        end
    end
end

local function startSectorRecording(sectorIndex)
    if not sectorIndex then return end
    app.currentRunMeasure[sectorIndex] = { {CAR.splinePosition, 0, gas = CAR.gas, brake = CAR.brake} }
    app.currentRunStartState[sectorIndex] = nil
    app.currentRunSector = sectorIndex
    if SectorRecord then
        ac.saveCarStateAsync(function(err, data)
            if not err then
                app.currentRunStartState[sectorIndex] = data
            end
        end)
    end
end

local function recordSectorSample(now)
    local sectorIndex = app.currentRunSector or app.liveSector
    if not app.liveStartClock or not sectorIndex then return end
    local measure = app.currentRunMeasure[sectorIndex]
    if not measure then return end

    local elapsedMs = math.floor((now - app.liveStartClock) * 1000)
    local last = measure[#measure]
    local lastTime = last and (last[2] or last.time) or -1
    if elapsedMs > lastTime then
        measure[#measure + 1] = {CAR.splinePosition, elapsedMs, gas = CAR.gas, brake = CAR.brake}
    end
end

local function startLiveTiming(sectorIndex, now)
        if not sectorIndex or CAR.isInPit then return end

        local nowClock = now or os.preciseClock()
        app.liveStartClock = nowClock
        app.liveSector = sectorIndex
        app.currentSectorTimer = 0

        startSectorRecording(sectorIndex)

        local ghost = app.ghostSectors[sectorIndex]
        if ghost and #ghost > 1 then
                local totalMs = app.ghostSectorDuration[sectorIndex] or 0
                if (not totalMs or totalMs <= 0) and app.ghostSectorTimeline[sectorIndex] then
                        local timeline = app.ghostSectorTimeline[sectorIndex]
                        if timeline and #timeline > 0 then
                                totalMs = timeline[#timeline].time
                        end
                end
                if (not totalMs or totalMs <= 0) and appData.sectorsdata.best[sectorIndex] then
                        totalMs = math.floor((appData.sectorsdata.best[sectorIndex] or 0) * 1000 + 0.5)
                end
                if totalMs and totalMs > 0 then
                        app.ghostPlayback.active = true
                        app.ghostPlayback.sector = sectorIndex
                        app.ghostPlayback.timeMs = 0
                        app.ghostPlayback.totalMs = totalMs
                else
                        resetGhostPlayback()
                end
        else
                resetGhostPlayback()
        end
end


-- ================= LÓGICA DE GUARDADO MANUAL =================

app.saveSectorState = function(sectorIndex)

    -- Determinar sector anterior
    local previous = sectorIndex - 1
    if previous < 1 then
        previous = appData.sector_count
    end
	
     -- Solo dejar guardar si estoy en el sector anterior
   if app.currentSector ~= previous then
        ui.toast(ui.Icons.Warning,"Para guardar S"..sectorIndex.." tenés que estar en el Sector "..previous)
        return
    end

        ac.saveCarStateAsync(function(err, data)
        if err then
            ui.toast(ui.Icons.Warning, "Error al guardar el estado del Sector "..sectorIndex)
            return
        end

        -- Guardar en memoria para esta sesión
        app.sectorStates[sectorIndex] = data

        -- Guardar en disco para esta pista+auto+sector
        local filePath = getSectorStatePath(sectorIndex)
        io.saveAsync(filePath, data)

        ui.toast(ui.Icons.Save, "Punto de retorno del Sector "..sectorIndex.." guardado.")
    end)
end


-- ================= LÓGICA DE TELETRANSPORTACIÓN =================

app.teleportToSector = function(sectorIndex, stateData)
    local state = stateData or app.sectorStates[sectorIndex]
    if state then
        -- Cargar el estado guardado para este sector
        ac.loadCarState(state, 30)

        -- Resetear timer live al teletransportar: no debe correr hasta cruzar la próxima línea de sector
        app.currentSectorStartClock = nil
        app.liveStartClock = nil
        app.liveSector = nil
        app.currentSectorTimer = 0
        app.currentRunMeasure = {}
        app.currentRunStartState = {}
        app.currentRunSector = nil
        resetGhostPlayback()

        -- Sincronizar el último sector conocido con el sector al que nos teletransportamos
        app.lastFrameSector = sectorIndex

        -- Reiniciar lógica del sector para practicar
        appData.sectorsValid[sectorIndex] = true
        app.currentSector = sectorIndex
        appData.mSectorsCheck.isValid = true
        appData.mSectorsCheck.current = 1
        appData.mSectorsCheck.startTime = os.preciseClock()

        ac.setMessage("Modo Práctica", "Sector " .. sectorIndex .. " Reiniciado")
        app.teleporting = true
        app.teleportCooldownUntil = os.preciseClock() + 1.0
        -- Pequeña pausa para evitar guardar estado mientras te teletransportas
        setTimeout(function() app.teleporting = false end, 1.0)

        app.lastReturnSector = sectorIndex
    end
end


-- ================= DIBUJADO DE UI =================

local MICRO_DELTA_SMALL = 0.10
local MS_COLOR_BEST = app.colors.PURPLE
local MS_COLOR_GREEN = app.colors.GREEN
local MS_COLOR_ORANGE = app.colors.ORANGE
local MS_COLOR_RED = app.colors.RED
local MS_COLOR_GRAY = app.colors.MID_GREY
local MS_COLOR_HIGHLIGHT = app.colors.CYAN

--- Dibuja las barras de micro-sectores y AHORA TAMBIÉN LOS BOTONES
local function drawmSectors(dt)
local mSectorWidth = app.uiDecay / 8
local basey = 104
local basex = 35

-- Línea gris superior
ui.drawSimpleLine(vec2(basex, basey-9), vec2(basex, basey+9), app.colors.GREY, 1)

local x
for i=1, appData.sector_count do
basex = app.uiDecay * (i-1) + 35
ui.pushID(i)
-- Dibujar barras de microsectores
for j=1, 8 do
local best = appData.sectorsdata.microBest[i] and appData.sectorsdata.microBest[i][j]
local last = appData.mSectorsLast[i] and appData.mSectorsLast[i][j]
local current = appData.mSectors[i][j]
local hasBest = best ~= nil and best > 0
local hasLast = last ~= nil and last > 0
local hasCurrent = current ~= nil and current > 0
local deltaBest = hasBest and hasCurrent and (current - best) or nil
local sectorIsInvalid = appData.sectorsValid[i] == false

local baseColor
if not hasBest or not hasCurrent or sectorIsInvalid then
baseColor = MS_COLOR_GRAY
elseif current < best then
baseColor = MS_COLOR_BEST
elseif hasLast and current < last then
baseColor = MS_COLOR_GREEN
elseif deltaBest ~= nil and deltaBest < MICRO_DELTA_SMALL then
baseColor = MS_COLOR_ORANGE
else
baseColor = MS_COLOR_RED
end
x = basex + (j-1)*mSectorWidth
local lineStart = vec2(x+1, basey)
local lineEnd = vec2(x+mSectorWidth, basey)
if i == app.currentSector and j == appData.mSectorsCheck.current then
ui.drawSimpleLine(vec2(lineStart.x-1, lineStart.y), vec2(lineEnd.x+1, lineEnd.y), MS_COLOR_HIGHLIGHT, 12)
end
ui.drawSimpleLine(lineStart, lineEnd, baseColor, 8)

local hitPos = vec2(x+1, basey - 4)
ui.setCursor(hitPos)
if ui.invisibleButton(string.format("msec_%d_%d", i, j), vec2(mSectorWidth, 8)) then
end

if ui.itemHovered() then
local currentText = hasCurrent and app.time_to_string(current) or "--.---"
local bestText = hasBest and app.time_to_string(best) or "--.---"

local deltaText = ""
if hasBest and hasCurrent then
local delta = current - best
local sign = delta >= 0 and "+" or ""
deltaText = string.format("  Δ: %s%.3f", sign, delta)
end

local tooltip = string.format(
"Sector S%d micro %d\nActual: %s%s\nBest:   %s",
i, j,
currentText,
deltaText,
bestText
)
ui.setTooltip(tooltip)
end
end

-- Línea divisoria vertical
ui.drawSimpleLine(vec2(basex + app.uiDecay, basey-90), vec2(basex + app.uiDecay, basey+9), app.colors.GREY, 1)

-- Etiqueta del Sector (S1, S2...)

local labelPos = vec2(basex + app.uiDecay - 20, basey + 8)  -- ajustá el 24 a gusto
ui.setCursor(labelPos)
if appData.sectorsValid[i] then
ui.dwriteText("S"..i, 15, app.colors.GREEN)
else
ui.dwriteText("S"..i, 15, app.colors.ORANGE)
end


-- === BOTÓN DE GUARDAR PUNTO DE RETORNO ===
local savePos = vec2(basex + app.uiDecay - 70, basey + 8)
ui.setCursor(savePos)
ui.pushStyleColor(ui.StyleColor.Text, rgbm(0.9, 0.9, 0.3, 1))  -- color “amarillo”
if ui.iconButton(ui.Icons.Save, vec2(18, 18)) then
app.saveSectorState(i)
end
ui.popStyleColor()

if ui.itemHovered() then
ui.setTooltip("Guardar punto de retorno para Sector "..i.." desde la posición actual")
end

-- === BOTÓN DE RETORNO (igual que antes) ===
local btnPos = vec2(basex + app.uiDecay - 45, basey + 8)
ui.setCursor(btnPos)

local hasState = app.sectorStates[i] ~= nil
local btnColor = hasState and rgbm(0, 1, 0, 1) or rgbm(1, 1, 1, 0.2)

ui.pushStyleColor(ui.StyleColor.Text, btnColor)
if ui.iconButton(ui.Icons.Restart, vec2(18, 18)) then
if hasState then
app.teleportToSector(i)
else
ui.toast(ui.Icons.Warning, "Todavía no guardaste el punto de retorno del Sector "..i)
end
end
ui.popStyleColor()


if ui.itemHovered() then
if hasState then
ui.setTooltip("Reiniciar Sector "..i)
else
ui.setTooltip("Punto de retorno no guardado aún.\nPasa por este sector para activarlo.")
end
end

ui.popID()
end

-- Línea inferior
ui.drawSimpleLine(vec2(0, basey+28), vec2(x+mSectorWidth, basey+28), app.colors.GREY, 1)
end

local function idealSectorTimeAtCurrentPos(sectorIndex)
        local startPos = appData.sectors[sectorIndex]
        local endPos = appData.sectors[sectorIndex + 1] or 1
        if not startPos or not endPos then return nil end

        local bestSectorTime = appData.sectorsdata.best[sectorIndex]
        if not bestSectorTime or bestSectorTime <= 0 then return nil end

        local spl = CAR.splinePosition
        if endPos < startPos then
                if spl < startPos then spl = spl + 1 end
                endPos = endPos + 1
        end

        local length = endPos - startPos
        if math.abs(length) < 1e-6 then
                return nil
        end

        local t = (spl - startPos) / length
        if t < 0 then t = 0 end
        if t > 1 then t = 1 end

        return bestSectorTime * t
end


function windowMainSettings(dt)
        local controlWidth = 160
        ui.text("Return button:")
        ui.sameLine(140)
        returnButton:control(vec2(controlWidth, 0))
        if ui.itemHovered() then
            ui.setTooltip("Teleports to the last saved/used return point.")
        end

        ui.text("Save Return button:")
        ui.sameLine(140)
        saveReturnButton:control(vec2(controlWidth, 0))
        if ui.itemHovered() then
            ui.setTooltip("Saves a return point for the next sector.")
        end

        ui.separator()
        ui.text("Edit sector target")
        for i=1, appData.sector_count do
                ui.pushItemWidth(80)
                local v, vChanged = ui.inputText('Sector '..i, appData.sectorsdata.target[i], 0)
                if vChanged and tonumber(v) ~= nil and tonumber(v) > 0 then
			appData.sectorsdata.target[i] = v
			app.saveCarData()
		end
        end
        ui.separator()
        ui.dwriteText('Session:', 12)
        ui.sameLine(80)
        ui.dwriteText(app.isOnline and 'Online' or 'Offline', 12)
        if ui.checkbox('Show ghost line', app.userData.settings.showGhostLine) then
                app.userData.settings.showGhostLine = not app.userData.settings.showGhostLine
                app.saveSettings(false)
        end
        if ui.checkbox('Show ghost car', app.userData.settings.showGhostCar) then
                app.userData.settings.showGhostCar = not app.userData.settings.showGhostCar
                app.saveSettings(false)
        end
    -- ... (resto de settings igual) ...
    if ui.checkbox('Force save CM personnal best', app.userData.settings.savepb) then
                app.userData.settings.savepb = not app.userData.settings.savepb
                if app.userData.settings.savepb then app.savePersonalBest(appData.pb) end
                app.saveSettings(false)
        end
end

-- Función principal de dibujado
function script.main(dt)
	ui.pushDWriteFont(app.font)

	local tSize = 13
	local title = app.title
	if app.sNotif ~= "" then title = string.format("%s - %s", title, app.sNotif) end
	ac.setWindowTitle('sectors', title)
	ac.setWindowBackground('sectors', app.colors.DARK_GREY)

	local lSum, bSum, tSum = 0, 0, 0
	local hasLast, hastTgt = true, true
	
	-- === Fila Live (tiempo en vivo del sector + delta) ===
	ui.offsetCursorX(-10)
	ui.offsetCursorY(-3)
        ui.dwriteText("Live", tSize)

        for i = 1, appData.sector_count do
                ui.sameLine(i * app.uiDecay - 70, 0)

                local timeNow = (i == app.liveSector) and app.currentSectorTimer or 0
                local timeStr = app.time_to_string(timeNow)
                if i == app.liveSector and timeNow > 0 and appData.sectorsValid[i] == false then
                        timeStr = timeStr .. "*"
                end
                ui.dwriteText(timeStr, tSize, app.colors.CYAN)

                -- Delta respecto al BEST del sector
                ui.sameLine(i * app.uiDecay - 17, 0)

                local deltaColor = app.colors.GREY
                local deltaText = "inv"

                if i == app.liveSector and timeNow > 0 then
                        local refTime = ghostTimeAtCurrentPos(i)
                        if refTime == nil then
                                refTime = idealSectorTimeAtCurrentPos(i)
                        end
                        if refTime ~= nil then
                                local delta = timeNow - refTime
                                deltaColor = (delta <= 0) and app.colors.GREEN or app.colors.RED
                                deltaText = string.format("%+.3fs", delta)
                        end
                end

                ui.dwriteText(deltaText, tSize - 1, deltaColor)
        end
        -- Fila Current (Last)
        ui.offsetCursorX(-10)
        ui.offsetCursorY(-3)
        ui.dwriteText("Last", tSize)
	for i=1, appData.sector_count do
		ui.sameLine(i*app.uiDecay - 70, 0)
                local lastTime = appData.current_sectors[i]
                local lastStr = app.time_to_string(lastTime)
                if lastTime > 0 and appData.sectorsValid[i] == false then
                        lastStr = lastStr .. "*"
                end
                if app.currentSector == i then
                        ui.dwriteTextHyperlink(lastStr, tSize, app.colors.WHITE)
                else
                        ui.dwriteText(lastStr, tSize)
                end

                color = app.colors.GREY
                if appData.current_sectors[i] == nil or appData.current_sectors[i] == 0 or appData.sectorsdata.best[i] == nil or appData.sectorsdata.best[i] == 0 then
                        app.delta = 'inv'
                        hasLast = false
                else
                        app.delta = appData.current_sectors[i] - appData.sectorsdata.best[i]
                        color = app.delta <= 0 and app.colors.GREEN or app.colors.RED
                        app.delta = string.format("%+.3fs", app.delta)
                end
                ui.sameLine(i*app.uiDecay - 17, 0)
                ui.dwriteText(app.delta, tSize-1, color)
                lSum = lSum + appData.current_sectors[i]
        end

	-- Fila Best
	ui.offsetCursorX(-10)
	ui.dwriteText("Best", tSize)
	for i=1, appData.sector_count do
		ui.sameLine(i*app.uiDecay - 70, 0)
		ui.dwriteText(app.time_to_string(appData.sectorsdata.best[i]), tSize, app.colors.PURPLE)
		if ui.itemClicked(ui.MouseButton.Right) then
			ui.modalPrompt('Reset Best time', 'Set best sector '..i..' time to', appData.sectorsdata.best[i], function (value)
				if value then appData.sectorsdata.best[i] = tonumber(value); app.saveCarData() end
			end)
		end
		if appData.sectorsdata.best[i] > 0 then
			color = app.colors.GREY
			app.delta = appData.sectorsdata.best[i] - appData.sectorsdata.target[i]
			if app.delta <= 0 then color = app.colors.ORANGE end
			if app.delta > 80 then app.delta = "inv" else app.delta = string.format("%.3fs", app.delta) end
			ui.sameLine(i*app.uiDecay - 17, 0)
			ui.dwriteText(app.delta, tSize-1, color)
			bSum = bSum + appData.sectorsdata.best[i]
		end
	end

	-- Fila Target
	ui.offsetCursorX(-10)
	ui.dwriteText("Tgt", tSize)
	for i=1, appData.sector_count do
		ui.sameLine(i*app.uiDecay - 70, 0)
		ui.dwriteText(app.time_to_string(appData.sectorsdata.target[i]), tSize, app.colors.YELLOW)
		if appData.sectorsdata.target[i] == nil or appData.sectorsdata.target[i] == 0 then hastTgt = false end
		tSum = tSum + appData.sectorsdata.target[i]
	end

	ui.offsetCursor(vec2(-10, 12))
	if CAR.wheelsOutside > app.userData.settings.allowedTyresOut then
		ui.dwriteText("off track!", tSize, app.colors.RED)
	else
		ui.dwriteText(" ", tSize, app.colors.RED)
	end

    -- DIBUJAR BARRAS Y BOTONES AQUI
	drawmSectors(dt)

    -- Footer stats
	ui.offsetCursor(vec2(-10, -1))
	ui.dwriteText("Last: "..app.time_to_string(app.sessionLastLapMs/1000), tSize, app.colors.GREY)
	ui.sameLine(120)
	ui.dwriteText("Sess Best: "..app.time_to_string(app.sessionBestLapMs/1000), tSize, app.colors.GREY)
	ui.sameLine(260)
	if appData.pb and appData.pb ~= math.huge then
		ui.dwriteText("Record: "..app.time_to_string(appData.pb/1000), tSize, app.colors.GREY)
	else
		ui.dwriteText("Record: "..app.time_to_string(0), tSize, app.colors.GREY)
	end

	ui.offsetCursor(vec2(-10, -4))
	ui.dwriteText("Target: "..app.time_to_string(tSum), tSize-2, app.colors.YELLOW)
	ui.sameLine(120)
	if hastTgt then
		ui.dwriteText(string.format('Theoric: %s  %.3fs', app.time_to_string(bSum), bSum - tSum), tSize-2, app.colors.PURPLE)
	else
		ui.dwriteText(string.format('Theoric: %s', app.time_to_string(bSum)), tSize-2, app.colors.PURPLE)
	end

        if hasLast then
                ui.sameLine(260)
                ui.dwriteText(string.format('Last: %.3fs', lSum - bSum), tSize-2, app.colors.GREY)
        end

        local ghost = app.ghostSectors[app.currentSector]
        ui.offsetCursor(vec2(-10, 4))
        --ui.dwriteText(string.format('Ghost S%d: %d pts', app.currentSector, ghost and #ghost or 0), 10, app.colors.GREY)

        ui.popDWriteFont()
end


local function isOutside()
        if CAR.wheelsOutside > app.userData.settings.allowedTyresOut then
                app.currentSectorValid = false
                appData.sectorsValid[app.currentSector] = false
                appData.mSectorsCheck.isValid = false
                app.currentRunMeasure[app.currentSector] = nil
                if app.currentRunSector == app.currentSector then
                        app.currentRunSector = nil
                end
                resetGhostPlayback()
                if not SIM.penaltiesEnabled and not app.isOnline then
                        ac.markLapAsSpoiled(false)
                        ac.setMessage('CUT DETECTED', 'LAP WILL NOT COUNT', 'illegal', 3)
                end
        end
end

local function mSectorsStep(currentSector)
        local splnPos = CAR.splinePosition
        local sectorStartPos = appData.sectors[currentSector]
        local sectorEndPos = currentSector < appData.sector_count and appData.sectors[currentSector+1] or 1
        local width = math.abs((sectorEndPos-sectorStartPos)/8)
        for i=0, 7 do
                if splnPos >= (sectorStartPos + i*width) and splnPos < (sectorStartPos + (i+1)*width) then
                        if i+1 ~= appData.mSectorsCheck.current then
                                local t = os.preciseClock() - appData.mSectorsCheck.startTime
                                local bestMicro = appData.sectorsdata.microBest[currentSector] and appData.sectorsdata.microBest[currentSector][i+1]
                                if appData.mSectorsCheck.isValid and bestMicro and bestMicro > 0 and t < bestMicro then
                                        appData.mSectorsisBest[currentSector][i+1] = 1
                                else
                                        appData.mSectorsisBest[currentSector][i+1] = 0
                                end
                                appData.mSectors[currentSector][i+1] = t
                                appData.mSectorsCheck.startTime = os.preciseClock()
                                appData.mSectorsCheck.current = i+1
                                appData.mSectorsCheck.isValid = true
                        end
                end
        end
end

-- ================= LOGICA DE CAPTURA DE ESTADO =================

local function checkSectorChangeAndCapture()
    local oldSector = app.lastFrameSector
    local newSector = app.currentSector

    -- Detectar cruce de sector para guardar estado.
    -- Tener en cuenta que el sector puede cambiar de forma no lineal (pits, restart, return),
    -- por lo que consideramos cualquier cambio real de sector.
    local justChanged = false
    if oldSector ~= nil and newSector ~= nil and newSector ~= oldSector then
        justChanged = true
    end

    if justChanged then
        ac.saveCarStateAsync(function(err, data)
            if not err then 
                app.sectorStates[newSector] = data 
                -- ac.log("Saved state for Sector " .. newSector) -- Debug
            end
        end)
    end

    app.lastFrameSector = newSector
end

function script.update(dt)
        isOutside()
        app.currentSector = app.getCurrentSector()

        local controlsEnabled = not SIM.isReplayActive and not SIM.isInMainMenu
        if controlsEnabled then
                if saveReturnButton:pressed() then
                        local currentSector = app.currentSector or 1
                        local nextSector = currentSector + 1
                        if currentSector == appData.sector_count then
                                nextSector = 1
                        end

                        app.saveSectorState(nextSector)
                        app.lastReturnSector = nextSector
                end

                if returnButton:pressed() then
                        local targetSector = app.lastReturnSector or 1
                        local state = app.sectorStates[targetSector]

                        if not state then
                                targetSector = 1
                                state = app.sectorStates[targetSector]
                                if not state then
                                        ui.toast(ui.Icons.Warning, "No return point saved for Sector 1")
                                        return
                                end
                        end

                        app.teleportToSector(targetSector)
                end
        end

        local now = os.preciseClock()
        local teleportActive = app.teleporting or (app.teleportCooldownUntil ~= nil and now < app.teleportCooldownUntil)
        local inPit = CAR.isInPit
        if app.teleportCooldownUntil ~= nil and now >= app.teleportCooldownUntil then
                app.teleportCooldownUntil = nil
        end

        local sectorStartedThisFrame = false

        -- Capturar estado si cambiamos de sector (deshabilitado por ahora)
        --if not app.teleporting and not SIM.isReplayActive then
        --    checkSectorChangeAndCapture()
        --end

        -- Timer en vivo del sector actual:
        -- solo corre después de cruzar al menos una línea de sector
        if teleportActive or inPit then
                app.currentSectorTimer = 0
                app.liveStartClock = nil
                app.liveSector = nil
                if teleportActive then
                        app.prevSectorTime = CAR.previousSectorTime
                        resetGhostPlayback()
                end
        elseif app.liveStartClock ~= nil then
                app.currentSectorTimer = now - app.liveStartClock
        else
                app.currentSectorTimer = 0
        end

        if not teleportActive and not inPit then
                local lastSector = app.lastFrameSector
                local currentSector = app.currentSector
                if lastSector and currentSector and currentSector ~= lastSector then
                        startLiveTiming(currentSector, now)
                        sectorStartedThisFrame = true
                end
        end

        recordSectorSample(now)

        if app.ghostPlayback.active and app.ghostPlayback.sector == app.currentSector and app.ghostPlayback.totalMs > 0 then
                app.ghostPlayback.timeMs = app.ghostPlayback.timeMs + dt * 1000
                if app.ghostPlayback.timeMs > app.ghostPlayback.totalMs then
                        app.ghostPlayback.timeMs = app.ghostPlayback.totalMs
                end
        end

        app.lastFrameSector = app.currentSector

        if CAR.isInPit then
                for i in ipairs(appData.sectorsValid) do appData.sectorsValid[i] = true end
        end

        if CAR.lapCount > appData.prevLapCount then
                for i in ipairs(appData.sectorsValid) do appData.sectorsValid[i] = true end
                appData.prevLapCount = CAR.lapCount > 0 and CAR.lapCount or SESSION.leaderboard[CAR.racePosition-1].laps
        end

        mSectorsStep(app.currentSector)

        -- Actualización de tiempos de sector y best (basado en app original),
        -- ignorando cambios provocados por teleports
        if not teleportActive and not inPit and app.prevSectorTime ~= CAR.previousSectorTime then
                local targetSector = app.getCurrentSector()
                if not sectorStartedThisFrame then
                        targetSector = targetSector or (((CAR.currentSector + 1) <= appData.sector_count) and (CAR.currentSector + 1) or 1)
                        startLiveTiming(targetSector, now)
                        sectorStartedThisFrame = true
                end
                -- AC referencia splits desde 0, tablas Lua desde 1
                app.prevSectorTime = CAR.lastSplits[appData.sector_count-1] or CAR.previousSectorTime
                if appData.sectorsdata.best[CAR.currentSector+1] == nil then
                        appData.sectorsdata.best[CAR.currentSector+1] = 0
                end

                -- Vuelta nueva: actualizar último sector
                if CAR.currentSector == 0 then
                        app.prevSectorTime = CAR.lastSplits[appData.sector_count-1] or app.prevSectorTime
                        app.prevSectorTime = app.prevSectorTime / 1000
                        if app.prevSectorTime ~= appData.current_sectors[appData.sector_count] then
                                appData.current_sectors[appData.sector_count] = app.prevSectorTime
                        end
                        if app.currentSectorValid then
                                copyCurrentMicroToLast(appData.sector_count)
                                if app.prevSectorTime ~= 0 and app.prevSectorTime < appData.sectorsdata.best[appData.sector_count]
                                        or appData.sectorsdata.best[appData.sector_count] == 0 then
                                        app.sNotif = "S" .. appData.sector_count .. " " ..
                                                string.format("%.3fs", app.prevSectorTime - appData.sectorsdata.best[appData.sector_count])
                                        appData.sectorsdata.best[appData.sector_count] = app.prevSectorTime
                                        appData.sectorsdata.microBest[appData.sector_count] = appData.sectorsdata.microBest[appData.sector_count] or {}
                                        for j=1, 8 do
                                                appData.sectorsdata.microBest[appData.sector_count][j] = appData.mSectors[appData.sector_count][j] or 0
                                        end
                                        app.saveCarData()
                                        saveSectorGhost(appData.sector_count, app.prevSectorTime)
                                end
                        end
                else
                        app.prevSectorTime = CAR.previousSectorTime / 1000
                        appData.current_sectors[CAR.currentSector] = app.prevSectorTime
                        if app.currentSectorValid then
                                copyCurrentMicroToLast(CAR.currentSector)
                                if app.prevSectorTime ~= 0 and app.prevSectorTime < appData.sectorsdata.best[CAR.currentSector]
                                        or appData.sectorsdata.best[CAR.currentSector] == 0 then
                                        app.sNotif = "S" .. CAR.currentSector .. " " ..
                                                string.format("%.3fs", app.prevSectorTime - appData.sectorsdata.best[CAR.currentSector])
                                        appData.sectorsdata.best[CAR.currentSector] = app.prevSectorTime
                                        appData.sectorsdata.microBest[CAR.currentSector] = appData.sectorsdata.microBest[CAR.currentSector] or {}
                                        for j=1, 8 do
                                                appData.sectorsdata.microBest[CAR.currentSector][j] = appData.mSectors[CAR.currentSector][j] or 0
                                        end
                                        app.saveCarData()
                                        saveSectorGhost(CAR.currentSector, app.prevSectorTime)
                                end
                        end
                end

		-- Personal best de vuelta (record tipo CM)
		if CAR.isLastLapValid and CAR.previousLapTimeMs ~= 0 then
			if appData.pb and CAR.previousLapTimeMs < appData.pb then
				appData.pb = CAR.previousLapTimeMs
				if app.userData.settings.savepb then
					app.savePersonalBest(CAR.previousLapTimeMs)
				end
			end
		end

        -- Last y Best de sesión, independientes del teletransporte
        if CAR.previousLapTimeMs > 0 and CAR.previousLapTimeMs ~= app.sessionLastLapMs then
            app.sessionLastLapMs = CAR.previousLapTimeMs
            if CAR.isLastLapValid and (app.sessionBestLapMs == 0 or CAR.previousLapTimeMs < app.sessionBestLapMs) then
                app.sessionBestLapMs = CAR.previousLapTimeMs
            end
        end

                app.prevSectorTime = CAR.previousSectorTime
                app.currentSectorValid = true
        end
end

render.on('main.track.transparent', function ()
        local showLine = app.userData.settings.showGhostLine
        local showCar = app.userData.settings.showGhostCar

        if not showLine and not showCar then return end

        local ghost = app.ghostSectors[app.currentSector]

        render.setBlendMode(render.BlendMode.AlphaBlend)
        render.setCullMode(render.CullMode.None)
        render.setDepthMode(render.DepthMode.ReadOnly)

        if showLine then
                for sectorIndex, ghostSector in pairs(app.ghostSectors) do
                        if ghostSector and #ghostSector >= 2 then
                                local ghostInputs = app.ghostInputs and app.ghostInputs[sectorIndex] or nil
                                for i = 1, #ghostSector - 1 do
                                        local color = app.ghostColor

                                        if ghostInputs and ghostInputs[i] then
                                                local ok, c = pcall(getGhostSegmentColor, ghostInputs[i])
                                                if ok and c then
                                                        color = c
                                                end
                                        end

                                        render.debugLine(ghostSector[i], ghostSector[i + 1], color, color)
                                end
                        end
                end
        end

        if showCar and app.ghostPlayback and app.ghostPlayback.active and app.ghostPlayback.sector == app.currentSector then
                local tMs = app.ghostPlayback.timeMs or 0
                local pos = getGhostPositionAtTime(app.currentSector, tMs)
                if pos then
                        local posNext = getGhostPositionAtTime(app.currentSector, tMs + 80)

                        if not posNext and ghost and #ghost >= 2 then
                                local totalMs = math.max(app.ghostPlayback.totalMs or 1, 1)
                                local ghostCount = #ghost
                                local maxIndex = ghostCount - 1
                                local t = math.min(math.max(tMs / totalMs, 0), 1)
                                local fIndex = t * maxIndex
                                local idx = math.floor(fIndex) + 1
                                if idx < 1 then idx = 1 end
                                if idx > ghostCount - 1 then idx = ghostCount - 1 end
                                posNext = ghost[idx + 1]
                        elseif posNext and ghost and (posNext - pos):length() < 0.05 then
                                local totalMs = math.max(app.ghostPlayback.totalMs or 1, 1)
                                local ghostCount = #ghost
                                local maxIndex = ghostCount - 1
                                local t = math.min(math.max(tMs / totalMs, 0), 1)
                                local fIndex = t * maxIndex
                                local idx = math.floor(fIndex) + 1
                                if idx < ghostCount then
                                        posNext = ghost[idx + 1]
                                elseif ghostCount > 1 then
                                        posNext = ghost[ghostCount - 1]
                                end
                        end

                        if posNext then
                                drawGhostCar(pos, posNext, app.ghostColor)
                        end
                end
        end
end)
ac.onSessionStart(function(sessionIndex, restarted)
        if restarted then app.init() end
end)

app.init()