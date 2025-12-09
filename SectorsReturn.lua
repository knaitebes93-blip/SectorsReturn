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
                },
        },
        ghostSectors = {},
        ghostColor = rgbm(0.8, 0.4, 1, 0.7),
        ghostSectorDuration = {},
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
	},
	pb = false
}

--- Inicializar micro sectores
app.set_microSectors = function()
	appData.mSectors = {}
	appData.mSectorsisBest = {}
	for i=1, appData.sector_count do
		appData.mSectors[i] = {}
		appData.mSectorsisBest[i] = {}
		for j=1, 8 do
			appData.mSectors[i][j] = 0
			appData.mSectorsisBest[i][j] = 0
		end
	end

	appData.mSectorsCheck = {
		current = 1,
		isValid = true,
		startTime = 0
	}
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
		app.userData.data[TRACK] = { best = {}, target = {} }
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
	for i=1, appData.sector_count do
		appData.current_sectors[i] = 0
		appData.sectorsdata.best[i] = appData.sectorsdata.best[i] or 0
		appData.sectorsdata.target[i] = appData.sectorsdata.target[i] or 0
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
    return string.format("%s\\%s_%s", ac.getFolder(ac.FolderID.ScriptConfig), ac.getTrackFullID('_'), ac.getCarID())
end

local function ensureGhostDir()
    local dir = getGhostDir()
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
    if pos == nil or time == nil then return nil end
    return {pos = pos, time = time}
end

local function buildInterpolatedGhost(measure)
    if type(measure) ~= 'table' then return {} end

    local cleaned = {}
    for _, v in ipairs(measure) do
        local parsed = parseMeasureEntry(v)
        if parsed then cleaned[#cleaned + 1] = parsed end
    end
    table.sort(cleaned, function(a, b) return a.time < b.time end)
    if #cleaned < 2 then return {} end

    local points = {}
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
    end

    points[#points + 1] = ac.trackProgressToWorldCoordinate(cleaned[#cleaned].pos % 1)
    return points
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

    local forward = nextPos - pos
    local forwardLen = forward:length()
    if not forwardLen or forwardLen < 0.01 then return end
    forward = forward / forwardLen

    local up = vec3(0, 1, 0)
    local right = forward:cross(up)
    local rightLen = right:length()
    if not rightLen or rightLen < 0.01 then
        right = vec3(1, 0, 0)
    else
        right = right / rightLen
    end

    local halfLength = 1.8
    local halfWidth = 0.6

    local frontCenter = pos + forward * halfLength
    local backCenter = pos - forward * halfLength

    local lf = frontCenter + right * halfWidth
    local rf = frontCenter - right * halfWidth
    local lb = backCenter + right * halfWidth
    local rb = backCenter - right * halfWidth

    render.debugLine(lf, rf, color, color)
    render.debugLine(rf, rb, color, color)
    render.debugLine(rb, lb, color, color)
    render.debugLine(lb, lf, color, color)

    render.debugLine(frontCenter, frontCenter + forward * 0.5, color, color)
end

function resetGhostPlayback()
    app.ghostPlayback.active = false
    app.ghostPlayback.sector = nil
    app.ghostPlayback.timeMs = 0
    app.ghostPlayback.totalMs = 0
end

app.loadSectorGhosts = function()
    app.ghostSectors = {}
    app.ghostSectorDuration = {}
    if not SectorRecord then return end

    local dir = getGhostDir()
    local ok, files = pcall(io.scanDir, dir, '*.lon')
    if not ok or not files then return end

    for _, file in ipairs(files) do
        local okRecord, record = pcall(SectorRecord, dir .. '/' .. file)
        if okRecord and record then
            local measure = record.measure or (record.data and record.data.measure)
            local finishingPoint = record.finishingPoint or (record.data and record.data.finishingPoint)
            local sectorIndex = getSectorIndexForProgress(finishingPoint)
            if sectorIndex and measure then
                local ghostPoints = buildInterpolatedGhost(measure)
                if #ghostPoints > 1 then
                    app.ghostSectors[sectorIndex] = ghostPoints
                    app.ghostSectorDuration[sectorIndex] = getMeasureDurationMs(measure)
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
            measureSorted[#measureSorted + 1] = {parsed.pos, parsed.time}
        end
    end
    table.sort(measureSorted, function(a, b) return (a[2] or 0) < (b[2] or 0) end)
    if #measureSorted == 0 then return end

    local lastEntry = measureSorted[#measureSorted]
    local lastTime = lastEntry[2] or 0
    if totalMs > lastTime or (lastEntry[1] ~= finishingPoint) then
        measureSorted[#measureSorted + 1] = {finishingPoint, totalMs}
    end

    local ghostPoints = buildInterpolatedGhost(measureSorted)
    if #ghostPoints > 1 then
        app.ghostSectors[sectorIndex] = ghostPoints
        app.ghostSectorDuration[sectorIndex] = totalMs
    end

    if not SectorRecord or not startState then return end

    local dir = ensureGhostDir()
    if not dir or not io.exists(dir) then return end

    local recordOk, record = pcall(SectorRecord, string.format('%s/ghost_S%d.lon', dir, sectorIndex), startState, startingPoint, finishingPoint)
    if not recordOk or not record then return end

    pcall(function()
        return record:register(totalMs, measureSorted)
    end)
    if #ghostPoints > 1 then
        app.ghostSectors[sectorIndex] = ghostPoints
    end
end

local function startSectorRecording(sectorIndex)
    if not sectorIndex then return end
    app.currentRunMeasure[sectorIndex] = { {CAR.splinePosition, 0} }
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
        measure[#measure + 1] = {CAR.splinePosition, elapsedMs}
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
			local color = appData.mSectorsisBest[i][j] == 0 and app.colors.MID_GREY or app.colors.PURPLE
			if i == app.currentSector and j == appData.mSectorsCheck.current then
				color = app.colors.YELLOW
			end
			x = basex + (j-1)*mSectorWidth
			ui.drawSimpleLine(vec2(x+1, basey), vec2(x+mSectorWidth, basey), color, 8)
		end
        
        -- Línea divisoria vertical
		ui.drawSimpleLine(vec2(basex + app.uiDecay, basey-90), vec2(basex + app.uiDecay, basey+9), app.colors.GREY, 1)

        -- Etiqueta del Sector (S1, S2...)
		ui.sameLine(basex + app.uiDecay - 20)
		if appData.sectorsValid[i] then
			ui.dwriteText("S"..i, 14, app.colors.GREEN)
		else
			ui.dwriteText("S"..i, 14, app.colors.ORANGE)
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

        local spl = CAR.splinePosition
        local length = endPos - startPos
        if math.abs(length) < 1e-6 then
                return nil
        end

        local t = (spl - startPos) / length
        if t < 0 then t = 0 end
        if t > 1 then t = 1 end

        local bestSectorTime = appData.sectorsdata.best[sectorIndex]
        if not bestSectorTime or bestSectorTime <= 0 then return nil end

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
        if ui.checkbox('Show Sector Ghost', app.userData.settings.showGhost) then
                app.userData.settings.showGhost = not app.userData.settings.showGhost
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
                ui.dwriteText(app.time_to_string(timeNow), tSize, app.colors.CYAN)

                -- Delta respecto al BEST del sector
                ui.sameLine(i * app.uiDecay - 17, 0)

                local deltaColor = app.colors.GREY
                local deltaText = "inv"

                if i == app.liveSector and timeNow > 0 then
                        local ideal = idealSectorTimeAtCurrentPos(i)
                        if ideal ~= nil then
                                local delta = timeNow - ideal
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
		if app.currentSector == i then
			ui.dwriteTextHyperlink(app.time_to_string(appData.current_sectors[i]), tSize, app.colors.WHITE)
		else
			ui.dwriteText(app.time_to_string(appData.current_sectors[i]), tSize)
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
        ui.dwriteText(string.format('Ghost S%d: %d pts', app.currentSector, ghost and #ghost or 0), 10, app.colors.GREY)

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
				if appData.mSectorsCheck.isValid and (t < appData.mSectors[currentSector][i+1] or appData.mSectors[currentSector][i+1] == 0) then
					appData.mSectorsisBest[currentSector][i+1] = 1
				else
					appData.mSectorsisBest[currentSector][i+1] = 0
				end
				appData.mSectors[currentSector][i+1] = os.preciseClock() - appData.mSectorsCheck.startTime
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
    if app.teleportCooldownUntil ~= nil and now >= app.teleportCooldownUntil then
        app.teleportCooldownUntil = nil
    end

    -- Capturar estado si cambiamos de sector (deshabilitado por ahora)
    --if not app.teleporting and not SIM.isReplayActive then
    --    checkSectorChangeAndCapture()
    --end

        -- Timer en vivo del sector actual:
        -- solo corre después de cruzar al menos una línea de sector
        if teleportActive then
                app.currentSectorTimer = 0
                app.liveStartClock = nil
                app.liveSector = nil
                app.prevSectorTime = CAR.previousSectorTime
                resetGhostPlayback()
        elseif app.liveStartClock ~= nil then
                app.currentSectorTimer = now - app.liveStartClock
        else
                app.currentSectorTimer = 0
        end

        if not teleportActive then
                local lastSector = app.lastFrameSector
                local currentSector = app.currentSector
                if lastSector ~= nil and currentSector ~= nil and currentSector ~= lastSector then
                        app.liveStartClock = now
                        app.liveSector = currentSector
                        app.currentSectorTimer = 0
                        startSectorRecording(currentSector)
                        local ghost = app.ghostSectors[currentSector]
                        if ghost and #ghost > 1 then
                                local totalMs = app.ghostSectorDuration[currentSector] or 0
                                if (not totalMs or totalMs <= 0) and appData.sectorsdata.best[currentSector] then
                                        totalMs = math.floor((appData.sectorsdata.best[currentSector] or 0) * 1000 + 0.5)
                                end
                                if totalMs and totalMs > 0 then
                                        app.ghostPlayback.active = true
                                        app.ghostPlayback.sector = currentSector
                                        app.ghostPlayback.timeMs = 0
                                        app.ghostPlayback.totalMs = totalMs
                                else
                                        resetGhostPlayback()
                                end
                        else
                                resetGhostPlayback()
                        end
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
        if not teleportActive and app.prevSectorTime ~= CAR.previousSectorTime then
                -- Reiniciar timer live al cruzar cualquier línea de sector
                app.liveStartClock = now
                app.liveSector = ((CAR.currentSector + 1) <= appData.sector_count) and (CAR.currentSector + 1) or 1
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
                                if app.prevSectorTime ~= 0 and app.prevSectorTime < appData.sectorsdata.best[appData.sector_count]
                                        or appData.sectorsdata.best[appData.sector_count] == 0 then
                                        app.sNotif = "S" .. appData.sector_count .. " " ..
                                                string.format("%.3fs", app.prevSectorTime - appData.sectorsdata.best[appData.sector_count])
                                        appData.sectorsdata.best[appData.sector_count] = app.prevSectorTime
                                        app.saveCarData()
                                        saveSectorGhost(appData.sector_count, app.prevSectorTime)
                                end
                        end
                else
                        app.prevSectorTime = CAR.previousSectorTime / 1000
                        appData.current_sectors[CAR.currentSector] = app.prevSectorTime
                        if app.currentSectorValid then
                                if app.prevSectorTime ~= 0 and app.prevSectorTime < appData.sectorsdata.best[CAR.currentSector]
                                        or appData.sectorsdata.best[CAR.currentSector] == 0 then
                                        app.sNotif = "S" .. CAR.currentSector .. " " ..
                                                string.format("%.3fs", app.prevSectorTime - appData.sectorsdata.best[CAR.currentSector])
                                        appData.sectorsdata.best[CAR.currentSector] = app.prevSectorTime
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
        if not app.userData.settings.showGhost then return end

        local ghost = app.ghostSectors[app.currentSector]
        if not ghost or #ghost < 2 then return end

        render.setBlendMode(render.BlendMode.AlphaBlend)
        render.setCullMode(render.CullMode.None)
        render.setDepthMode(render.DepthMode.ReadOnly)

        for i = 1, #ghost - 1 do
                render.debugLine(ghost[i], ghost[i + 1], app.ghostColor, app.ghostColor)
        end

        if app.ghostPlayback and app.ghostPlayback.active and app.ghostPlayback.sector == app.currentSector then
                local tMs = app.ghostPlayback.timeMs or 0
                local pos = getGhostPositionAtTime(app.currentSector, tMs)
                if pos then
                        local posNext = getGhostPositionAtTime(app.currentSector, tMs + 80)

                        if not posNext then
                                local totalMs = math.max(app.ghostPlayback.totalMs or 1, 1)
                                local ghostCount = #ghost
                                local maxIndex = ghostCount - 1
                                local t = math.min(math.max(tMs / totalMs, 0), 1)
                                local fIndex = t * maxIndex
                                local idx = math.floor(fIndex) + 1
                                if idx < 1 then idx = 1 end
                                if idx > ghostCount - 1 then idx = ghostCount - 1 end
                                posNext = ghost[idx + 1]
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