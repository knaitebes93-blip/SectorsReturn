-- JumpAIline by leBluem

-- textures used,     first one is the original texture from '/content/texture/ideal_line.png'
local TexturesAILine = {}
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/content/texture/ideal_line.png')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_mono.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_mono_slim.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_mono_slim_tiny.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_5.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_7.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_6.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_8.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_9.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_10.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_11.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_12.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_13.dds')
table.insert(TexturesAILine, ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/ideal_line_14.png')

local texBorder            = ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/bordertex.dds'

local trackMeshes = ac.findNodes('trackRoot:yes'):findMeshes("?")
local carMeshes = ac.findNodes('carsRoot:yes'):findMeshes("?")
local acpobjects = ac.findNodes('trackRoot:yes'):findMeshes("AC_POBJECT?")
if #acpobjects>0 then
ac.setWindowTitle('main',
    tostring(#trackMeshes).." track"..
    "  /  "..
    tostring(#carMeshes).." car" ..
    "  /  "..
    tostring(#acpobjects).." phy" ..
" - JumpAILine v3.3")
else
    ac.setWindowTitle('main',
    tostring(#trackMeshes).." track"..
    "  /  "..
    tostring(#carMeshes).." car" ..
" - JumpAILine v3.3")
end
--v3.3 - 20 apr 2025
-- -added optional overlay for Ghostfiles from all cars on current track (drawn in border color)
-- -same for CSV-files from ...Document\Assetto Corsa\Ghost\trackname\
-- -same for /data/groveline.csv
-- -increased max for glow
--v3.2 - 18 mar 2025
-- -better fading, borders fade too
-- -added third option to color AI line by angle only
-- -other small fixes
--
--v3.1 - 5 mar 2025
-- -fixed marker not working with ai line off
-- -fixed marker glow
-- -fixed some issue on startup
--
--v3.0 - 3 mar 2025
-- -fixed using wrong blendmode (black or overexposed ai line)
-- -fixed default texture loading (typo)
-- -fixed issue not finding Sabine-Schmitz-Kurve after putting it in
-- -removed debug info
-- redone ai line coloring, added corner marker
-- added 4 simple frame controls in section window when in replay
--
--v2.9 - 18 feb 2025
-- -fixed not showing first sectorname on track
-- -fixed drawing inconsistently around start/finish
-- -fixed AI red offset, was off by a factor of 2
-- -fixed MEM jump again, also for the button
-- -added ideal line length option as for borders too
-- -only one option now for rendered parts/partlen
-- -switched to only render prev/curr/next sectornames on track, before it was distance based, limited to 400m

-- -cleaned up settings window, added ideal graphic preview, 2 new graphics (basic lines)
-- -switched to .dds images for the ideal-graphic (except first one is still original AC texture
-- -note that when using "ideal_line.ai" you may need more "lead in", PoT is somehow wrong there
-- -added option for the 4 Nordschleife layouts to update the sections.ini,
-- --replacing Hatzenbachbogen with Sabine-Schmitz-Kurve
-- -MEM/jump MEM now also saved per track+layout

--
--v2.8 - 12 feb 2025
--fixed glow
--more range for AI offset: from 1-400% percent, was 25-400
--
--v2.7 - 8 feb 2025
--added option to use other available ai lines
--added back first original coloring mode without fading ("fade colors" option)
--rendering border: using a texture now ("bordertex.dds" in app folder)
--custom AI-multiplier is now saved "per car"
--fixed glowmult again, now 2 separate options for ai-line/border glow
--fixed new color fading mode not hiding green ai line parts
--fixed an error when sectionnames should be rendered on track without "sections.ini"
--Note: Be aware, that borders from ai-line are not showing you valid surfaces!
--  Its mainly for the ai to stay on track
--
--v2.6.1 - 26 jan 2025
--refined "Corner names on track" to be always on and not only show when you are inside a corner
---changed to depend on camera position, so also works in free camera mode
--
--v2.6 - 24 jan 2025
--added Corner names on track, and optional control bindings
--
--v2.52 - 11 dec 2024
--sorry for fast update AGAIN
--fixed single color AI line still getting brighter in corners
--
--v2.51 - 11 dec 2024
--sorry for fast update
--added key/button binds for new features
--fixed not being pushed when using key-binds, push was already there when using ui buttons
--
--v2.5 - 11 dec 2024
--fixed arrangement of some ui parts
--fixed AI line not shrinked to road in tunnels
--added option to draw AI line with a single color
--added option to offset AI yellow/red coloring, from 0.5 to 5.0 (50 to 500 percent)
--adjusted lowest glowmult brightness to be same as AC ai-line
--added "MEM" and "jump MEM" buttons,
----"MEM" saves your current car position and direction
----"jump MEM" jumps to saved car position and sets same direction (be careful on another track :) )
--
--v2.4 - 12 nov 2024
-- fixed loading next/prev option, thx @Damgam!
--
--v2.3 - 23 oct 2024
-- fixed loading some options, thx @Skuby!
-- fixed messed up section names (ie on Brands Hatch Indy)
-- added option to hide sections reload button
--
--v2.2 - 11 oct 2024
-- Kindly added by ___@Damgam___, thank you very much!
-- --added smoothly fading colors to dynamic ai line
-- added 6 more ai line graphics
-- added option to skip parts in ai line
--
--v2.1 - 1 sept 2024
-- small fix to make border/ideal buttons work when game is paused
--
--v2.0 - 30 aug 2024
-- fixed glow with/without LCS
-- re-added FFB silencing before jumps
-- added option to change ai border color
--
--v1.9 - 11 july 2024
-- fixed prev/next sections display
--
--v1.8 - 3 july 2024
-- fixed bugs
--
--v1.7 - 2 july 2024
-- fixed silly "#" mistakes
--
--v1.6 - 1 july 2024
-- dynamic ideal line now also working with CSP 0.2.3
-- added drawing ideal/border a bit backwards too
-- removed ffb thing as it would reset your ffb to 0 in some cases
--
--v1.5 - 25 june 2024
-- fixed last fix not fixing what it should have fixed
--
--v1.4 - 21 june 2024
-- border/ideal being available too in all other modes than practice/hotlap
--
--v1.3 - 12 june 2024
-- added AI line rendering with dynamic yellow/red parts, 4 different ideal graphics available
-- reload button for "sections.ini"
-- added dropdown for Section-names
-- added PointOfTrack (PoT) display to km's, click to copy value
-- added fontsize/color/glow mult/buttons as options
--
--v1.2 - 30 april 2024
-- fixed folder missing for the app in ..ac\apps\lua\
-- FFB is turned off when jumping
--
--v1.1 - 28 april 2024
-- AI borders are projected to ground
-- added control mapping for ai borders, rendered length has a slider now
-- made km/sections optional
--
--v1.0 - 26 april 2024
-- initial version

-- function GetFilename(path)
--     local start, finish = path:find('[%w%s!-={-|]+[_%.].+')
--     return path:sub(start,#path)
-- end

local function readACConfig(ini, sec, key, def)
    local inifile = ac.INIConfig.load(ini)
    return inifile:get(sec, key, def)
end

local function writeACConfig(ini, sec, key, val)
    local inifile = ac.INIConfig.load(ini)
    inifile:set(sec, key, val)
    inifile:save(ini)
end

local BIdealC={}
local BIdealL={}
local BIdealR={}
local BLeft={}
local BRight={}
local BLeft2={}
local BRight2={}
local BDir={}
local BGas={}
local BBrake={}
local Sects = {}

local BGhostDir={}
local BGhostIdealL={}
local BGhostIdealR={}
local BGhostIdealC={}

local idealscale = 1
local gapdefault = 0.3
local raydist = 8
local upd = 0.0
local vUp = vec3(0, 1, 0)
local vDown = vec3(0, -1, 0)
local ucTurn = vec2(0.0, 0.0)

-- project to ground
local function snapToTrackSurface(pos, gap)
    local p = pos
    local v1 = vec3()
    local d = physics.raycastTrack(v1:set(p):add(vUp*raydist/2), vDown, raydist, p)
    if d>=0.0 then
        pos.y = p.y + (gap or 0.03)
    else
        pos.y = p.y - 0.25 + gap
    end
end


-- trackMeshes:dispose()
-- carMeshes:dispose()
-- local trackroot = ac.findNodes('trackRoot:yes')
-- -- local trackMeshes --@ac.SceneReference
-- local hitMesh = ac.emptySceneReference()
-- "Documents\Assetto Corsa\cfg\gameplay.ini"
-- local gameplayini = ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/cfg/gameplay.ini"
-- local USE_MPH = ac.INIConfig.load(gameplayini):get('OPTIONS', 'USE_MPH', 0)
-- local sTrack = string.lower( ac.getTrackID() )
-- local sLayout = string.lower( ac.getTrackLayout() )
-- ac.debug("sTrack", sTrack)

local sectINI = ""
local acini = ac.getFolder('ac.FolderID.Root')..'/system/cfg/assetto_corsa.ini'
local vidini = ac.getFolder('ac.FolderID.Cfg')..'/video.ini'
local appini = 'apps/lua/JumpAILine/JumpAILine.ini'

local sim = ac.getSim()
local car = ac.getCar(0)
local carp = ac.getCarPhysics(0)
local carNode = ac.findNodes('carRoot:0')
local carstw = carNode:findNodes('STEER_HR')
carMeshes = carstw:findMeshes('?')

local pushForce = 150
local second = 0.0
local secondadd = 0.25
local currSect = -1
local prevSect = nil
local nextSect = nil
local keydelay = 0.0

local ffbTimer = 0.0
local lastFFB = 0.0

local exposure = (math.max(0.1, ac.getSim().whiteReferencePoint/10))
-- local exposure2 = (math.max(0.1, ac.getSim().whiteReferencePoint/10))


-- local bDrawWalls = false  -- or lines when false
local bDrawWalls = true

local sCar = string.lower( tostring(ac.getCarID(0)) )
local CUSTOM_MULT = tonumber( readACConfig(appini, 'AI_MULT_PER_CAR', sCar, 1.0) )
-- local CUSTOM_MULT = tonumber( readACConfig(appini, 'USERSETTINGS', 'CUSTOM_MULT', 1.0) )
local glowmult   = math.min(10, math.max(0.5, tonumber( readACConfig(appini, 'USERSETTINGS', 'GLOWMULT', 1.0) )))
local glowmultB   = math.min(10, math.max(0.5, tonumber( readACConfig(appini, 'USERSETTINGS', 'GLOWMULTBORDER', 1.0) )))
local jumpdist   = math.floor(tonumber( readACConfig(appini, 'USERSETTINGS', 'JUMPDIST', 50) ))
-- draw AI line and borders a bit behind the car
local leadinCount = math.floor(tonumber( readACConfig(appini, 'USERSETTINGS', 'LEADINCOUNT', 10) ))
-- rendered IdealLine parts
local ai_renderlength = math.floor(tonumber( readACConfig(appini, 'USERSETTINGS', 'AI_RENDERLENGTH', 120) ))
-- rendered Border parts
local border_renderlength = math.floor(tonumber( readACConfig(appini, 'USERSETTINGS', 'BORDER_RENDERLENGTH', 200) ))
-- part length in meters
local partlen = math.floor(math.max(1, math.floor ( readACConfig(appini, 'USERSETTINGS', 'AILINE_DISTANCE', 2)) ))

local ghostfileID = readACConfig(appini, 'USERSETTINGS', 'GHOSTID', 0)

local ghostfile = ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/"
local sTrack = string.lower( ac.getTrackID() )
local sLayout = string.lower( ac.getTrackLayout() )
local BGhostFiles = {}
local BGhostDetail = {}

local brdDist = 1  --- .5525/2 --math.floor ( readACConfig(appini, 'USERSETTINGS', 'BORDER_DISTANCE', 1) )
-- percent of spline length
--local borderDist = brdDist/sim.trackLengthM   --- those meters above in percent of track
--local borderDist = 1  --- those meters above in percent of track
local rgbSections = rgbm.colors.white
local rgbCurrentSection --@rgbm
local rgbSingleColor --@rgbm
local editcolor --@rgbm
local editcolor2 --@rgbm
local editcolor3 --@rgbm
local rgbBorder --@rgbm




local textsteer = ''
local textdriver = ''
local p1 = vec3(0,0,0)
local p2 = vec3(0,0,0)
local p3 = vec3(0,0,0)
local dist = 0.0
local tooltimer = 0.0
local tooltimer5 = 1.0
local cnti = 1
local tooltimer2 = 0.1
local sesstimeleft = sim.sessionTimeLeft+0.002

local WheelHidden = tonumber( readACConfig(vidini, 'ASSETTOCORSA', 'HIDE_STEER', '0') )
local DriverHidden = tonumber( readACConfig(acini, 'DRIVER', 'HIDE', '0') )

local fntSize = 18 --@integer
local fntSizeSmall = 12 --@integer
fntSize = math.floor( tonumber( readACConfig(appini, 'USERSETTINGS', 'FONTSIZE', 18) ))
fntSizeSmall = math.floor(0.666*fntSize)

local idealTexture = math.floor(tonumber( readACConfig(appini, 'USERSETTINGS', 'IDEALTEXTURE', 1) ))
local texAIline = TexturesAILine[idealTexture]

local joystickbuttonideal      = ac.ControlButton('__APP_JumpAILINE_ideal')
local joystickbuttonreset      = ac.ControlButton('__APP_JumpAILINE_reset')
local joystickbuttonstepback   = ac.ControlButton('__APP_JumpAILINE_stepback')
local joystickbuttonstepforw   = ac.ControlButton('__APP_JumpAILINE_stepforw')
local joystickbuttonsectPrev   = ac.ControlButton('__APP_JumpAILINE_sectPrev')
local joystickbuttonsectNext   = ac.ControlButton('__APP_JumpAILINE_sectNext')
local joystickbuttonAI         = ac.ControlButton('__APP_JumpAILINE_AI')
local joystickbuttonMEM        = ac.ControlButton('__APP_JumpAILINE_MEM')
local joystickbuttonJUMPMEM    = ac.ControlButton('__APP_JumpAILINE_JUMPMEM')
local joystickbuttonAIoffsetUP = ac.ControlButton('__APP_JumpAILINE_AIoffsetUP')
local joystickbuttonAIoffsetDN = ac.ControlButton('__APP_JumpAILINE_AIoffsetDN')
local joystickbuttonCornerNames= ac.ControlButton('__APP_JumpAILINE_Cornernames')

local bBackground                = false --$boolean
if readACConfig(appini, 'CONTROLS', 'BACKGROUND'     , "0") == "1" then bBackground = true end
local bSections                  = true --$boolean
if readACConfig(appini, 'CONTROLS', 'Sections'       , "1") == "0" then bSections = false end
local bAIonlyWhenNotGreen        = true --$boolean
if readACConfig(appini, 'CONTROLS', 'AIWHENNOTGREEN' , "1") == "0" then bAIonlyWhenNotGreen = false end
local bAIonlyWhenNotYellow       = true --$boolean
if readACConfig(appini, 'CONTROLS', 'AIWHENNOTYELLOW', "1") == "0" then bAIonlyWhenNotYellow = false end
local bButtonReload              = true --$boolean
if readACConfig(appini, 'CONTROLS', 'ButtonReload'   , "1") == "0" then bButtonReload = false end

local iDoColorFade  = tonumber(readACConfig(appini, 'CONTROLS', 'DoColorFade', "0"))

local bKMs           = false --$boolean
if readACConfig(appini, 'CONTROLS', 'KMs'       , "0") == "1" then bKMs = true end
local bPoT           = false --$boolean
if readACConfig(appini, 'CONTROLS', 'PoT'       , "0") == "1" then bPoT = true end
local bButtons       = false --$boolean
if readACConfig(appini, 'CONTROLS', 'Buttons'   , "0") == "1" then bButtons = true end
local bAIborders     = false --$boolean
if readACConfig(appini, 'CONTROLS', 'AIBORDERS' , "0") == "1" then bAIborders = true end
local bAIideal       = false --$boolean
if readACConfig(appini, 'CONTROLS', 'AIIDEAL'   , "0") == "1" then bAIideal = true end
local bAImonocolor   = false --$boolean
if readACConfig(appini, 'CONTROLS', 'AIMONOCOLOR'   , "0") == "1" then bAImonocolor = true end
local bDriveHint     = false --$boolean
if readACConfig(appini, 'USERSETTINGS', 'DriveHint'   , "0") == "1" then bDriveHint = true end
local bDebugText     = false --$boolean
if readACConfig(appini, 'USERSETTINGS', 'DebugText'   , "0") == "1" then bDebugText = true end
local bCornerArrow   = false --$boolean
if readACConfig(appini, 'USERSETTINGS', 'CornerArrow'   , "0") == "1" then bCornerArrow = true end

local AIskipVar = tonumber ( readACConfig(appini, 'CONTROLS', 'SKIPAIPARTS', 1) )
--$integer

local bDrawCornersOnTrack = false --$boolean
if readACConfig(appini, 'USERSETTINGS', 'CORNERNAMESONTRACK', "0") == "1" then bDrawCornersOnTrack = true end




local scol = readACConfig(appini, 'USERSETTINGS', "SECTIONCOLOR", "0.5,1,0.5,1")
if scol~="" then
    local col = string.split(scol,',')
    rgbCurrentSection = rgbm(tonumber(col[1]), tonumber(col[2]), tonumber(col[3]), 1)
    editcolor = rgbCurrentSection:clone()
end

scol = readACConfig(appini, 'USERSETTINGS', "BORDERCOLOR", "1,0,0,1")
if scol~="" then
    local col = string.split(scol,',')
    rgbBorder = rgbm(tonumber(col[1]), tonumber(col[2]), tonumber(col[3]), 1)
    editcolor2 = rgbBorder:clone()
end

scol = readACConfig(appini, 'USERSETTINGS', "AISINGLECOLOR", "0,1,0,1")
if scol~="" then
    local col = string.split(scol,',')
    rgbSingleColor = rgbm(tonumber(col[1]), tonumber(col[2]), tonumber(col[3]), 1)
    editcolor3 = rgbSingleColor:clone()
end

local function GetVector(pos1, pos2, distance)
    local direction = (pos2 - pos1)
    return pos1 + (direction * distance)
end

------------------------------------------------------------------------
local function laptime(timestamp)
    if (timestamp==nil or timestamp < 0) then
        return "--.---"
    elseif timestamp==0.0 then
        return "0:00.000"
    end

    --local function pad(n, z) z = z || 2; return ('00' + n).slice(-z); end
    local milliseconds = timestamp % 1000
    timestamp = (timestamp - milliseconds) / 1000
    local seconds = timestamp % 60
    timestamp = (timestamp - seconds) / 60
    local minutes = timestamp % 60
    local hours = (timestamp - minutes) / 60
    --local ms = tostring(milliseconds):pad(3, "0", -1)
    local ms = string.format("%03d", milliseconds)
    local ss = tostring(seconds):pad(2, "0", -1)
    local hh = tostring(hours):pad(2, "0", -1)
    if (hours > 0) then
        local mm = tostring(minutes):pad(1, "0", -1)
        return hh..":"..mm..":"..ss.."."..ms
    elseif (minutes > 0) then
        local mm = tostring(minutes):pad(1, "0", -1)
        return mm..":"..ss.."."..ms
    else
        local mm = tostring(minutes):pad(1, "0", -1)
        return mm..":"..ss.."."..ms
    end
end

-- local function get_date_from_unix(unix_time)
--     local day_count, year, days, month = function(yr) return (yr % 4 == 0 and (yr % 100 ~= 0 or yr % 400 == 0)) and 366 or 365 end, 1970, math.ceil(unix_time/86400)

--     while days >= day_count(year) do
--         days = days - day_count(year) year = year + 1
--     end
--     local tab_overflow = function(seed, table) for i = 1, #table do if seed - table[i] <= 0 then return i, seed end seed = seed - table[i] end end
--     month, days = tab_overflow(days, {31,(day_count(year) == 366 and 29 or 28),31,30,31,30,31,31,30,31,30,31})
--     local hours, minutes, seconds = math.floor(unix_time / 3600 % 24), math.floor(unix_time / 60 % 60), math.floor(unix_time % 60)
--     local period = hours > 12 and "pm" or "am"
--     hours = hours > 12 and hours - 12 or hours == 0 and 12 or hours
--     return string.format("%d/%d/%04d %02d:%02d:%02d %s", days, month, year, hours, minutes, seconds, period)
-- end
------------------------------------------------------------------------------------------









local function CreateBorders()
    if car ~= nil then
        table.clear(BGas)
        table.clear(BBrake)
        table.clear(BIdealC)
        table.clear(BIdealL)
        table.clear(BIdealR)
        table.clear(BLeft)
        table.clear(BRight)
        table.clear(BLeft2)
        table.clear(BRight2)
        table.clear(BDir)
        local cSpline2 = 1.0 - 1/sim.trackLengthM
        p2 = ac.trackProgressToWorldCoordinate(cSpline2)
        cSpline2 = 0
        p1 = ac.trackProgressToWorldCoordinate(cSpline2)
        local bABtrack = p1:distance(p2) > 10
        local side = ac.getTrackAISplineSides(cSpline2)
        local lastdir = -10000.0
        local c = 0

        while cSpline2 < 1.0 do  --- - 1/sim.trackLengthM do
            local dir = -math.deg( math.atan2(p1.z-p2.z, p1.x-p2.x) )
            -- local roll = -math.deg( math.atan2(p1.x-p2.x, p1.z-p2.z) )
            local vL = vec3(p1.x + math.cos((dir + 90) * math.pi / 180)*idealscale, p1.y, p1.z - math.sin((dir + 90) * math.pi / 180)*idealscale)
            local vR = vec3(p1.x + math.cos((dir - 90) * math.pi / 180)*idealscale, p1.y, p1.z - math.sin((dir - 90) * math.pi / 180)*idealscale)
            snapToTrackSurface(vL, 0.05)
            snapToTrackSurface(vR, 0.05)

            local xL = p1.x + math.cos((dir + 90) * math.pi / 180) * side.x
            local yL = p1.z - math.sin((dir + 90) * math.pi / 180) * side.x
            local xR = p1.x + math.cos((dir - 90) * math.pi / 180) * side.y
            local yR = p1.z - math.sin((dir - 90) * math.pi / 180) * side.y
            local zL = p1.y
            local zR = p1.y
            local p4 = vec3(xL, zL, yL)
            local p5 = vec3(xR, zR, yR)

            snapToTrackSurface(p1, 0.05)
            snapToTrackSurface(p4, 0.3)
            snapToTrackSurface(p5, 0.3)
            local pL2 = vec3(p4.x, p4.y-0.35, p4.z)
            local pR2 = vec3(p5.x, p5.y-0.35, p5.z)

            table.insert(BIdealC, p1)
            table.insert(BIdealL, vL)
            table.insert(BIdealR, vR)
            table.insert(BLeft, p4)
            table.insert(BRight, p5)
            table.insert(BLeft2, pL2)
            table.insert(BRight2, pR2)
            table.insert(BDir, math.rad(dir-90))
            table.insert(BGas   , 1)
            table.insert(BBrake , 0)

            -- ac.debug("distIDEAL  "..tostring(#BIdealC), tostring(p1:distance(p2)))
            p1:copyTo(p2)
            cSpline2 = cSpline2 + 1/sim.trackLengthM
            p1 = ac.trackProgressToWorldCoordinate(cSpline2)
            side = ac.getTrackAISplineSides(cSpline2)
            lastdir = dir
        end -- while

        if not bABtrack and #BIdealC>0 then
            table.insert(BIdealC, GetVector(BIdealC[#BIdealC], BIdealC[1], 0.5))
            table.insert(BIdealL, GetVector(BIdealL[#BIdealL], BIdealL[1], 0.5))
            table.insert(BIdealR, GetVector(BIdealR[#BIdealR], BIdealR[1], 0.5))
            table.insert(BLeft  , GetVector(BLeft  [#BLeft  ], BLeft  [1], 0.5))
            table.insert(BRight , GetVector(BRight [#BRight ], BRight [1], 0.5))
            table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 ], BLeft2 [1], 0.5))
            table.insert(BRight2, GetVector(BRight2[#BRight2], BRight2[1], 0.5))
            table.insert(BDir   , BDir[#BDir])
            table.insert(BGas   , (BGas[#BGas]+BGas[1])/2)
            table.insert(BBrake , (BBrake[#BBrake]+BBrake[1])/2)
        end

        -- must interpolate first bc might be a strange distance from last
        --ac.debug("#", #BIdealC)
        -- if not bABtrack and #BIdealC>0 then
        --     BIdealC [1] = vec3((BIdealC [2].x+BIdealC [#BIdealC ].x)/2, (BIdealC [2].y+BIdealC [#BIdealC ].y)/2, (BIdealC [2].z+BIdealC [#BIdealC ].z)/2)
        --     BIdealL [1] = vec3((BIdealL [2].x+BIdealL [#BIdealL ].x)/2, (BIdealL [2].y+BIdealL [#BIdealL ].y)/2, (BIdealL [2].z+BIdealL [#BIdealL ].z)/2)
        --     BIdealR [1] = vec3((BIdealR [2].x+BIdealR [#BIdealR ].x)/2, (BIdealR [2].y+BIdealR [#BIdealR ].y)/2, (BIdealR [2].z+BIdealR [#BIdealR ].z)/2)
        --     BLeft   [1] = vec3((BLeft  [2].x+BLeft  [#BLeft  ].x)/2, (BLeft  [2].y+BLeft  [#BLeft  ].y)/2, (BLeft  [2].z+BLeft  [#BLeft  ].z)/2)
        --     BRight  [1] = vec3((BRight [2].x+BRight [#BRight ].x)/2, (BRight [2].y+BRight [#BRight ].y)/2, (BRight [2].z+BRight [#BRight ].z)/2)
        --     BLeft2  [1] = vec3((BLeft2  [2].x+BLeft2  [#BLeft2  ].x)/2, (BLeft2  [2].y+BLeft2  [#BLeft2  ].y)/2, (BLeft2  [2].z+BLeft2  [#BLeft2  ].z)/2)
        --     BRight2 [1] = vec3((BRight2 [2].x+BRight2 [#BRight2 ].x)/2, (BRight2 [2].y+BRight2 [#BRight2 ].y)/2, (BRight2 [2].z+BRight2 [#BRight2 ].z)/2)
        --     -- need even number of parts
        --     if #BIdealL % 2 == 0 then
        --         table.insert(BIdealC, GetVector(BIdealC[#BIdealC], BIdealC[1], 0.5))
        --         table.insert(BIdealL, GetVector(BIdealL[#BIdealL], BIdealL[1], 0.5))
        --         table.insert(BIdealR, GetVector(BIdealR[#BIdealR], BIdealR[1], 0.5))
        --         table.insert(BLeft  , GetVector(BLeft  [#BLeft  ], BLeft  [1], 0.5))
        --         table.insert(BRight , GetVector(BRight [#BRight ], BRight [1], 0.5))
        --         table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 ], BLeft2 [1], 0.5))
        --         table.insert(BRight2, GetVector(BRight2[#BRight2], BRight2[1], 0.5))
        --         table.insert(BDir   , BDir[#BDir])
        --         table.insert(BGas   , (BGas[#BGas]+BGas[1])/2)
        --         table.insert(BBrake , (BBrake[#BBrake]+BBrake[1])/2)
        --     end
        -- end
        -- table.insert(BIdealL, GetVector(BIdealL[#BIdealL-1], BIdealL[#BIdealL], 0.5))
        -- table.insert(BIdealR, GetVector(BIdealR[#BIdealR-1], BIdealR[#BIdealR], 0.5))
        -- table.insert(BLeft  , GetVector(BLeft  [#BLeft  -1], BLeft  [#BLeft  ], 0.5))
        -- table.insert(BRight , GetVector(BRight [#BRight -1], BRight [#BRight ], 0.5))
        -- table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 -1], BLeft2 [#BLeft2 ], 0.5))
        -- table.insert(BRight2, GetVector(BRight2[#BRight2-1], BRight2[#BRight2], 0.5))
        -- table.insert(BGas   , BGas[#BGas])
        -- table.insert(BBrake , BBrake[#BBrake])
        -- table.insert(BDir   , BDir[#BDir])

        ai_renderlength = math.min(ai_renderlength, #BIdealL)

    end
end


local function ReadAILINE(Filename)
    table.clear(BGas)
    table.clear(BBrake)
    table.clear(BIdealC)
    table.clear(BIdealL)
    table.clear(BIdealR)
    table.clear(BLeft)
    table.clear(BRight)
    table.clear(BLeft2)
    table.clear(BRight2)
    table.clear(BDir)

    local f = io.open(Filename, 'rb')
    if not f then
        ac.debug("could not open: ", Filename)
    else
        ac.debug("reading: ", Filename)
        -- ac.perfBegin('load fast_lane')
        local pos
        local lastdir = -1080
        local content = f:read("a")
        f:close()

        -- ac.debug("lll", #content)
        if #content<32 then return end

        -- 4 floats -- header, detailCount, u1, u2
        local header, detailCount, u1, u2 = 0, 0, 0, 0
        header, pos = string.unpack("=I4", content, pos)
        detailCount, pos = string.unpack("=I4", content, pos)
        _, pos = string.unpack("=I4", content, pos)
        _, pos = string.unpack("=I4", content, pos)

        local BIdealCenter = table.new(detailCount,0)
        local x,y,z=0.0,0.0,0.0
        local xl,yl,zl,distl,idl=0.0,0.0,0.0,0.0,0
        local gas, brake, sidex, sidey, gasl, brakel = 0.0, 1.0, 1.0, 1.0, 1.0, 1.0

        -- ideal line data
        for i = 1, detailCount do
            -- 4 floats, one integer
            x,    pos = string.unpack("=f", content, pos)
            y,    pos = string.unpack("=f", content, pos)
            z,    pos = string.unpack("=f", content, pos)
            _,    pos = string.unpack("=f", content, pos) -- dist
            _,    pos = string.unpack("=I4", content, pos) -- id
            p1 = vec3(x,y,z)
            snapToTrackSurface(p1, gapdefault)
            table.insert(BIdealCenter, p1)
            p1:copyTo(p2)
        end
        if #BIdealCenter==0 then
            return
        end

        local vLl=vec3(0,0,0)
        local vRl=vec3(0,0,0)
        local pLl=vec3(0,0,0)
        local pRl=vec3(0,0,0)
        local pLl2=vec3(0,0,0)
        local pRl2=vec3(0,0,0)
        local vL = vec3(0,0,0)
        local vR = vec3(0,0,0)
        local pL = vec3(0,0,0)
        local pR = vec3(0,0,0)
        local pL2 = vec3(0,0,0)
        local pR2 = vec3(0,0,0)
        xl,yl,zl =BIdealCenter[#BIdealCenter].x, BIdealCenter[#BIdealCenter].y, BIdealCenter[#BIdealCenter].z
        lastdir = -math.deg( math.atan2(BIdealCenter[1].z-BIdealCenter[#BIdealCenter].z,BIdealCenter[1].x-BIdealCenter[#BIdealCenter].x) )
        local dir = lastdir
        local sidexl = 0
        local sideyl = 0
        local ray = render.createRay(vec3(0,0,0), vDown, 10)


        -- detail data including sides
        for i = 1, #BIdealCenter do
            x,y,z=BIdealCenter[i].x, BIdealCenter[i].y, BIdealCenter[i].z
            -- 20 floats
            -- _          , pos = string.unpack("=f", content, pos)  -- unk            float()  0
            -- _          , pos = string.unpack("=f", content, pos)  -- speed          float()  1
            pos=pos+2*4
            gas        , pos = string.unpack("=f", content, pos)  -- gas            float()  2
            brake      , pos = string.unpack("=f", content, pos)  -- brake          float()  3
            -- _          , pos = string.unpack("=f", content, pos)  -- obsoleteLatG   float()  4
            -- _          , pos = string.unpack("=f", content, pos)  -- radius         float()  5
            pos=pos+2*4
            sidex      , pos  =string.unpack("=f", content, pos)  -- sideLeft       float()  6
            sidey      , pos  =string.unpack("=f", content, pos)  -- sideRight      float()  7
            -- _          , pos = string.unpack("=f", content, pos)  -- camber         float()  8
            -- _          , pos = string.unpack("=f", content, pos)  -- direction      vec3x()  9
            -- _          , pos = string.unpack("=f", content, pos)  -- normalx        vec3y() 10
            -- _          , pos = string.unpack("=f", content, pos)  -- normaly        vec3z() 11
            -- _          , pos = string.unpack("=f", content, pos)  -- normalz        float() 12
            -- _          , pos = string.unpack("=f", content, pos)  -- length         vec3x() 13
            -- _          , pos = string.unpack("=f", content, pos)  -- forwardVectorx vec3y() 14
            -- _          , pos = string.unpack("=f", content, pos)  -- forwardVectory vec3z() 15
            -- _          , pos = string.unpack("=f", content, pos)  -- forwardVectorz float() 16
            -- _          , pos = string.unpack("=f", content, pos)  -- tag            float() 17
            pos=pos+10*4

            dir  = -math.deg( math.atan2(z-zl,x-xl) )
            -- local roll = -math.deg( math.atan2(x-xl, z-zl) )
            vL = vec3(x + math.cos((dir + 90) * math.pi / 180)*idealscale, y, z - math.sin((dir + 90) * math.pi / 180)*idealscale)
            vR = vec3(x + math.cos((dir - 90) * math.pi / 180)*idealscale, y, z - math.sin((dir - 90) * math.pi / 180)*idealscale)
            snapToTrackSurface(vL, 0.05)
            snapToTrackSurface(vR, 0.05)

            pL = vec3(x + math.cos((dir + 90) * math.pi / 180)*sidex     , y, z - math.sin((dir + 90) * math.pi / 180)*sidex     )
            pR = vec3(x + math.cos((dir - 90) * math.pi / 180)*sidey     , y, z - math.sin((dir - 90) * math.pi / 180)*sidey     )
            snapToTrackSurface(pL, 0.3)
            snapToTrackSurface(pR, 0.3)
            pL2 = vec3(pL.x, pL.y-0.35, pL.z)
            pR2 = vec3(pR.x, pR.y-0.35, pR.z)

            if i>1 then

                -- ac.debug("distREADAILINE  "..tostring(#BIdealCenter), tostring(BIdealCenter[i]:distance(BIdealCenter[i-1])))

                if i==2 then
                    -- insert first point
                    table.insert(BIdealC, BIdealCenter[1])
                    table.insert(BIdealL, vLl)
                    table.insert(BIdealR, vRl)
                    table.insert(BLeft  , pLl)
                    table.insert(BRight , pRl)
                    table.insert(BLeft2 , pLl2)
                    table.insert(BRight2, pRl2)
                    table.insert(BGas   , gasl)
                    table.insert(BBrake , brakel)
                    table.insert(BDir   , math.rad(lastdir))
                    -- insert second interpolated point
                    table.insert(BIdealC, GetVector(BIdealCenter[1], BIdealCenter[2], 0.5))
                    table.insert(BIdealL, GetVector(vLl , vL , 0.5))
                    table.insert(BIdealR, GetVector(vRl , vR , 0.5))
                    table.insert(BLeft  , GetVector(pLl , pL , 0.5))
                    table.insert(BRight , GetVector(pRl , pR , 0.5))
                    table.insert(BLeft2 , GetVector(pLl2, pL2, 0.5))
                    table.insert(BRight2, GetVector(pRl2, pR2, 0.5))
                    table.insert(BGas   , (gas+gasl)/2)
                    table.insert(BBrake , (brake+brakel)/2)
                    table.insert(BDir   , (math.rad(lastdir+dir))/2)
                end
                if i==26 then
                    -- insert intermediate points for those missing points on ai line
                    table.insert(BIdealC, GetVector(BIdealCenter[i-1], BIdealCenter[i], 0.25))
                    table.insert(BIdealL, GetVector(vLl , vL                          , 0.25))
                    table.insert(BIdealR, GetVector(vRl , vR                          , 0.25))
                    table.insert(BLeft  , GetVector(pLl , pL                          , 0.25))
                    table.insert(BRight , GetVector(pRl , pR                          , 0.25))
                    table.insert(BLeft2 , GetVector(pLl2, pL2                         , 0.25))
                    table.insert(BRight2, GetVector(pRl2, pR2                         , 0.25))
                    table.insert(BGas   , gasl)
                    table.insert(BBrake , brakel)
                    table.insert(BDir   , math.rad(lastdir))

                    table.insert(BIdealC, GetVector(BIdealCenter[i-1], BIdealCenter[i], 0.5))
                    table.insert(BIdealL, GetVector(vLl , vL                          , 0.5))
                    table.insert(BIdealR, GetVector(vRl , vR                          , 0.5))
                    table.insert(BLeft  , GetVector(pLl , pL                          , 0.5))
                    table.insert(BRight , GetVector(pRl , pR                          , 0.5))
                    table.insert(BLeft2 , GetVector(pLl2, pL2                         , 0.5))
                    table.insert(BRight2, GetVector(pRl2, pR2                         , 0.5))
                    table.insert(BGas   , gasl)
                    table.insert(BBrake , brakel)
                    table.insert(BDir   , math.rad(lastdir))

                    table.insert(BIdealC, GetVector(BIdealCenter[i-1], BIdealCenter[i], 0.75))
                    table.insert(BIdealL, GetVector(vLl , vL                          , 0.75))
                    table.insert(BIdealR, GetVector(vRl , vR                          , 0.75))
                    table.insert(BLeft  , GetVector(pLl , pL                          , 0.75))
                    table.insert(BRight , GetVector(pRl , pR                          , 0.75))
                    table.insert(BLeft2 , GetVector(pLl2, pL2                         , 0.75))
                    table.insert(BRight2, GetVector(pRl2, pR2                         , 0.75))
                    table.insert(BGas   , gasl)
                    table.insert(BBrake , brakel)
                    table.insert(BDir   , math.rad(lastdir))
                else
                    -- insert interpolated point
                    table.insert(BIdealC, GetVector(BIdealCenter[i-1], BIdealCenter[i], 0.5))
                    table.insert(BIdealL, GetVector(vLl , vL , 0.5))
                    table.insert(BIdealR, GetVector(vRl , vR , 0.5))
                    table.insert(BLeft  , GetVector(pLl , pL , 0.5))
                    table.insert(BRight , GetVector(pRl , pR , 0.5))
                    table.insert(BLeft2 , GetVector(pLl2, pL2, 0.5))
                    table.insert(BRight2, GetVector(pRl2, pR2, 0.5))
                    table.insert(BGas   , (gas+gasl)/2)
                    table.insert(BBrake , (brake+brakel)/2)
                    table.insert(BDir   , (math.rad(lastdir+dir))/2)
                end

                -- all the points
                table.insert(BIdealC, BIdealCenter[i])
                table.insert(BIdealL, vL)
                table.insert(BIdealR, vR)
                table.insert(BLeft  , pL)
                table.insert(BRight , pR)
                table.insert(BLeft2 , pL2)
                table.insert(BRight2, pR2)
                table.insert(BGas   , gas)
                table.insert(BBrake , brake)
                table.insert(BDir   , math.rad(dir))
            end
            xl,yl,zl= x, y, z
            gasl, brakel, lastdir = gas, brake, dir
            sidexl, sideyl = sidex, sidey
            vL:copyTo(vLl)
            vR:copyTo(vRl)
            pL:copyTo(pLl)
            pR:copyTo(pRl)
            pL2:copyTo(pLl2)
            pR2:copyTo(pRl2)
            if pos+4*20>#content then
                ac.debug("Incomplete line: ", Filename)
                ac.debug("Incomplete line count: ", #BIdealL)
                break
            end
        end

        -- need even number of parts
        --if #BIdealL % 2 ~= 0 and not abtrack then
        if #BIdealL % 2 ~= 0  then
            table.insert(BIdealC, GetVector(BIdealC[#BIdealC], BIdealC[1], 0.75))
            table.insert(BIdealL, GetVector(BIdealL[#BIdealL], BIdealL[1], 0.75))
            table.insert(BIdealR, GetVector(BIdealR[#BIdealR], BIdealR[1], 0.75))
            table.insert(BLeft  , GetVector(BLeft  [#BLeft  ], BLeft  [1], 0.75))
            table.insert(BRight , GetVector(BRight [#BRight ], BRight [1], 0.75))
            table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 ], BLeft2 [1], 0.75))
            table.insert(BRight2, GetVector(BRight2[#BRight2], BRight2[1], 0.75))
            table.insert(BDir   , (BDir[#BDir]+BDir[1])/2)
            table.insert(BGas   , (BGas[#BGas]+BGas[1])/2)
            table.insert(BBrake , (BBrake[#BBrake]+BBrake[1])/2)
            -- table.insert(BIdealL, GetVector(BIdealL[#BIdealL], BIdealL[1], 0.3333))
            -- table.insert(BIdealR, GetVector(BIdealR[#BIdealR], BIdealR[1], 0.3333))
            -- table.insert(BLeft  , GetVector(BLeft  [#BLeft  ], BLeft  [1], 0.3333))
            -- table.insert(BRight , GetVector(BRight [#BRight ], BRight [1], 0.3333))
            -- table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 ], BLeft2 [1], 0.3333))
            -- table.insert(BRight2, GetVector(BRight2[#BRight2], BRight2[1], 0.3333))
            -- table.insert(BGas   , gasl)
            -- table.insert(BBrake , brakel)
            -- table.insert(BDir   , math.rad(lastdir))
        end
        -- table.insert(BIdealL, GetVector(BIdealL[#BIdealL], BIdealL[1], 0.6666))
        -- table.insert(BIdealR, GetVector(BIdealR[#BIdealR], BIdealR[1], 0.6666))
        -- table.insert(BLeft  , GetVector(BLeft  [#BLeft  ], BLeft  [1], 0.6666))
        -- table.insert(BRight , GetVector(BRight [#BRight ], BRight [1], 0.6666))
        -- table.insert(BLeft2 , GetVector(BLeft2 [#BLeft2 ], BLeft2 [1], 0.6666))
        -- table.insert(BRight2, GetVector(BRight2[#BRight2], BRight2[1], 0.6666))
        -- table.insert(BGas   , BGas[#BGas])
        -- table.insert(BBrake , BBrake[#BBrake])
        -- table.insert(BDir   , BDir[#BDir])

        ai_renderlength = math.min(ai_renderlength, #BIdealL)
        -- ai_renderlength = math.min(ai_renderlength, #BIdealL)
        --borderDist = 1/(#BLeft)/2    --- those meters above in percent of track
        --borderDist = 1/(#BGas)         --- those meters above in percent of track

        -- save to file for testing
        -- local f2 = io.open("p:/Steam/steamapps/common/assettocorsa/apps/lua/jumpailine/bleft2.csv", 'w')
        -- if f2 then
        --     for i = 1, #BLeft2 do
        --         f2:write(math.round(BLeft2[i].x,4)..","..
        --                  math.round(BLeft2[i].y,4)..","..
        --                  math.round(-BLeft2[i].z,4)..","..
        --                  math.round(i/#BLeft2,6).."\n")
        --     end
        --     f2:close()
        -- end
    end
end

local function IsBasicCSV(s)
    local valid = tostring("0123456789,.-")
    for i=1, #s do
        if not string.find(valid, s[i]) then
            return false
        end
    end
    return true
end


local function ReadCSVFile(csvfile, doTimeOnly)
    if io.fileExists(csvfile) then
        local ghdate = os.date("%A, %m %B %Y %H:%M",tonumber(io.getAttributes(csvfile).lastWriteTime))
        local ghtime = ""

        local f = io.open(csvfile, 'r')
        if not f then
            ac.debug("could not open '.csv'", csvfile)
            return -1, -1
        else
            BGhostIdealC={}
            BGhostIdealL={}
            BGhostIdealR={}
            BGhostDir={}

            local ptdist = 1.0
            local pos = 0
            local lines = f:read("a"):split("\n")
            f:close()

            local colX, colY, colZ = 0,0,0
            local lineid = 0
            local switchY = false

            for i=1, #lines do
                if IsBasicCSV(lines[i]) then
                    local ll = string.split(lines[i], ",")
                    if #ll==3 or #ll==4 then
                        colX, colY, colZ = 1,2,3
                        lineid = 1
                        switchY = true
                        break
                    end
                end

                --"Time","Distance","Corr Speed","Chassis World Pos X","Chassis World Pos Y","Chassis World Pos Z","Chassis Angle World X","Chassis Angle World Y","Chassis Angle World Z","Lap Progression"
                if  tostring(lines[i]):find("Log Date") then
                    ghdate = lines[i]:split(",")[2]:replace('"','')
                    -- "Log Date","4/9/2025",,,"Origin Time","2053.877","s"
                    -- "Log Time","7:08:18 PM",,,"Start Time","2053.880","s"
                    -- "Sample Rate","100.000","Hz",,"End Time","2165.870","s"
                    -- "Duration","111.990","s",,"Start Distance","90838","m"
                end
                if  tostring(lines[i]):find("Log Time") then
                    ghdate = ghdate .. " " .. lines[i]:split(",")[2]:replace('"','')
                end
                if  tostring(lines[i]):find("Duration") then
                    local tmp = lines[i]:split(",")[2]:replace('"',''):replace('.','')
                    ghtime = laptime( tonumber (tmp) )
                end

                if  tostring(lines[i]):find("World Pos X") and
                    tostring(lines[i]):find("World Pos Y") and
                    tostring(lines[i]):find("World Pos Z")
                then
                    local cols = lines[i]:split(",")
                    for j=1, #cols do
                        if tostring(cols[j]):find("World Pos X") then colX=j end
                        if tostring(cols[j]):find("World Pos Y") then colY=j end
                        if tostring(cols[j]):find("World Pos Z") then colZ=j end
                    end
                    lineid = i + 2
                    break
                end
            end

            if not (colX>0 and colY>0 and colZ>0) or lineid==0 then
                return ghtime, ghdate
            end

            if doTimeOnly then
                return ghtime, ghdate
            end


            ac.debug("came here", "sdfsad")
            ac.debug("#lines", #lines)
            ac.debug("colX", colX)

            local s=""
            local roll = 0.0
            local dir = 0.0
            local meters = 0.0
            local imeters = 0
            local vdir = vec3(0,0,0)
            local pC = vec3(0,0,0)
            local vL = vec3(0,0,0)
            local vR = vec3(0,0,0)
            ptdist = #BIdealC / sim.trackLengthM
            -- ptdist = sim.trackLengthM / #BIdealC
            ac.debug("ptdist", ptdist)

            while lineid < #lines do
                if lines[lineid]~="" then
                    local cols = lines[lineid]:split(",")
                    -- ac.debug("lineid", lineid)
                    -- ac.debug("colX", colX)
                    -- ac.debug("cols[colX]", cols[colX]:replace('"','') )
                    -- if true then
                    -- return end
                    local x = cols[colX]:replace('"','')
                    local y = cols[colY]:replace('"','')
                    local z = cols[colZ]:replace('"','')
                    if switchY then
                        z = -z
                    end

                    p2.x=tonumber(x)
                    p2.y=tonumber(y)
                    p2.z=tonumber(z)
                    if #BGhostIdealC==0 then
                        --p1=vec3(TabB0[i], TabB1[i], TabB2[i])
                        table.insert(BGhostIdealC, p1)
                        table.insert(BGhostIdealL, p1)
                        table.insert(BGhostIdealR, p1)
                        table.insert(BGhostDir, 0)
                        p2:copyTo(p1)
                    else
                        dist = p1:distance(p2)
                        if dist > 1.27 then
                            dir = -math.deg( math.atan2(p2.z-p1.z, p2.x-p1.x) )
                            vdir = (p2-p1)/dist
                            local pT = p1 + (vdir)
                            vL = vec3(pT.x + math.cos((dir + 90) * math.pi / 180)*idealscale, pT.y, pT.z - math.sin((dir + 90) * math.pi / 180)*idealscale)
                            vR = vec3(pT.x + math.cos((dir - 90) * math.pi / 180)*idealscale, pT.y, pT.z - math.sin((dir - 90) * math.pi / 180)*idealscale)
                            snapToTrackSurface(pT, 0.05)
                            snapToTrackSurface(vR, 0.05)
                            snapToTrackSurface(vL, 0.05)

                            if #BGhostDir == 1 then
                                -- update first point
                                BGhostIdealL[1] = vL
                                BGhostIdealR[1] = vR
                                BGhostDir[1] = math.rad(dir-90)
                            end

                            table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC], pT, 0.5))
                            table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL], vL, 0.5))
                            table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR], vR, 0.5))
                            table.insert(BGhostDir, math.rad(dir-90))

                            table.insert(BGhostIdealC, pT)
                            table.insert(BGhostIdealL, vL)
                            table.insert(BGhostIdealR, vR)
                            table.insert(BGhostDir, math.rad(dir-90))

                            p2:copyTo(p1)
                        end
                    end
                end
                lineid=lineid+1
            end

            return ghtime, ghdate
        end
    end
    -- ac.debug("ghtime", ghtime)
    -- ac.debug("ghdaze", ghdate)
end


local function ReadGhostFile(ghostfile, doTimeOnly)
    if io.fileExists(ghostfile) then
        local ghdate = os.date("%A, %m %B %Y %H:%M",tonumber(io.getAttributes(ghostfile).lastWriteTime))
        local f = io.open(ghostfile, 'rb')
        if not f then
            ac.debug("could not open '.ghost'", ghostfile)
            return -1, -1
        else
            local ptdist = 1.0
            local pos = 0
            local content = f:read("a")
            f:close()

            local header, sig, len1, len2, len3, len4
            header,pos   = string.unpack("=I4", content, pos)
            sig   ,pos   = string.unpack("=I4", content, pos)
            len1,pos     = string.unpack("=I4", content, pos)
            -- ac.debug('user', len1)
            pos = pos + len1
            len2, pos    = string.unpack("=I4", content, pos)
            -- ac.debug('track', len2)
            pos = pos + len2
            len3, pos    = string.unpack("=I4", content, pos)
            -- ac.debug('layout', len3)
            pos = pos + len3
            len4         = string.unpack("=I4", content, pos)
            -- ac.debug('len4', len4)
            pos = pos + len4 + 4

            -- ac.debug('pos', pos)
            local ghtime, pos   = string.unpack("=I4", content, pos)
            if doTimeOnly then
                return laptime(ghtime), ghdate
            end

            local detailCount=0
            detailCount, pos = string.unpack("=I4", content, pos)
            detailCount = detailCount * 4
            --detailCount,pos = string.unpack("=I4", content, pos)
            -- ac.debug('detailCount', detailCount)

            BGhostIdealC={}
            BGhostIdealL={}
            BGhostIdealR={}
            BGhostDir={}
            TabB0 = table.new(detailCount,0)
            TabB1 = table.new(detailCount,0)
            TabB2 = table.new(detailCount,0)
            TabB3 = table.new(detailCount,0)

            local s=""
            local roll = 0.0
            local dir = 0.0
            local meters = 0.0
            local imeters = 0
            local vdir = vec3(0,0,0)
            local pC = vec3(0,0,0)
            local pC = vec3(0,0,0)
            local pC = vec3(0,0,0)
            local vL = vec3(0,0,0)
            local vR = vec3(0,0,0)
            --ptdist = #BIdealC / sim.trackLengthM
            --ptdist = sim.trackLengthM / #BIdealC
            ptdist = 1.6666
            ac.debug("ptdist1", ptdist)
            for i = 1, detailCount do
                TabB0[i],pos = string.unpack("=f", content, pos)
                TabB1[i],pos = string.unpack("=f", content, pos)
                TabB2[i],pos = string.unpack("=f", content, pos)
                TabB3[i],pos = string.unpack("=f", content, pos)
                -- s = s .. TabB0[i]..", "..TabB1[i]..", "..TabB2[i]..", "..TabB3[i]..'\n'

                if tostring(TabB3[i]) == "1" then
                    -- ac.debug("s  "..i, s)
                    -- s=""
                    if #BGhostIdealC==0 then
                        p1=vec3(TabB0[i], TabB1[i], TabB2[i])
                        table.insert(BGhostIdealC, p1)
                        table.insert(BGhostIdealL, p1)
                        table.insert(BGhostIdealR, p1)
                        table.insert(BGhostDir, 0)
                    else

                        p2 = vec3(TabB0[i], TabB1[i], TabB2[i])
                        dir = -math.deg( math.atan2(p2.z-p1.z, p2.x-p1.x) )
                        dist = p1:distance(p2)
                        if ptdist==1.6666 then
                            ptdist = dist/4
                            ac.debug("ptdist2", ptdist)
                        end
                        -- roll = math.deg( math.atan(p2.x-p1.x, p2.y-p1.y) )

                        -- table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC], p2, 0.5))
                        -- table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL], vL, 0.5))
                        -- table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR], vR, 0.5))
                        -- table.insert(BGhostDir, math.rad(dir-90))

                        -- table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC], p2, 0.25))
                        -- table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL], vL, 0.25))
                        -- table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR], vR, 0.25))
                        -- table.insert(BGhostDir, math.rad(dir-90))
                        -- table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC-1], p2, 0.75))
                        -- table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL-1], vL, 0.75))
                        -- table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR-1], vR, 0.75))
                        -- table.insert(BGhostDir, math.rad(dir-90))


                        if dist>1.5 then
                            meters = meters + dist
                            vdir = (p2-p1)/dist
                            local c=1
                            while imeters < math.ceil(meters)
                                --   and
                                --   c < math.floor(dist)
                            do
                                local pT = p1 + (vdir) * c
                                vL = vec3(pT.x + math.cos((dir + 90) * math.pi / 180)*idealscale, pT.y, pT.z - math.sin((dir + 90) * math.pi / 180)*idealscale)
                                vR = vec3(pT.x + math.cos((dir - 90) * math.pi / 180)*idealscale, pT.y, pT.z - math.sin((dir - 90) * math.pi / 180)*idealscale)
                                snapToTrackSurface(pT, 0.05)
                                snapToTrackSurface(vR, 0.05)
                                snapToTrackSurface(vL, 0.05)

                                if #BGhostDir == 1 then
                                    BGhostIdealL[1] = vL
                                    BGhostIdealR[1] = vR
                                    BGhostDir[1] = math.rad(dir-90)
                                end
                                if #BGhostIdealC==47 then
                                table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC  ], pT, 0.25))
                                table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL  ], vL, 0.25))
                                table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR  ], vR, 0.25))
                                table.insert(BGhostDir, math.rad(dir-90))
                                -- table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC-2], pT, 0.75))
                                -- table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL-2], vL, 0.75))
                                -- table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR-2], vR, 0.75))
                                -- table.insert(BGhostDir, math.rad(dir-90))
                                -- table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC  ], pT, 0.5))
                                -- table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL  ], vL, 0.5))
                                -- table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR  ], vR, 0.5))
                                -- table.insert(BGhostDir, math.rad(dir-90))
                                end

                                table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC], pT, 0.5))
                                table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL], vL, 0.5))
                                table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR], vR, 0.5))
                                table.insert(BGhostDir, math.rad(dir-90))

                                if #BGhostIdealC==47 then
                                    table.insert(BGhostIdealC, GetVector(BGhostIdealC[#BGhostIdealC-2], pT, 0.75))
                                    table.insert(BGhostIdealL, GetVector(BGhostIdealL[#BGhostIdealL-2], vL, 0.75))
                                    table.insert(BGhostIdealR, GetVector(BGhostIdealR[#BGhostIdealR-2], vR, 0.75))
                                    table.insert(BGhostDir, math.rad(dir-90))
                                end

                                table.insert(BGhostIdealC, pT)
                                table.insert(BGhostIdealL, vL)
                                table.insert(BGhostIdealR, vR)
                                table.insert(BGhostDir, math.rad(dir-90))

                                imeters=imeters+ptdist
                                c=c+ptdist
                            end
                        end
                        p2:copyTo(p1)
                    end
                end

                -- just overread those
                pos = pos + 4*8 * 4
                -- _,pos = string.unpack("=f", content, pos) -- wFL
                -- _,pos = string.unpack("=f", content, pos) -- wFL
                -- _,pos = string.unpack("=f", content, pos) -- wFL
                -- _,pos = string.unpack("=f", content, pos) -- wFL
                -- _,pos = string.unpack("=f", content, pos) -- wFR
                -- _,pos = string.unpack("=f", content, pos) -- wFR
                -- _,pos = string.unpack("=f", content, pos) -- wFR
                -- _,pos = string.unpack("=f", content, pos) -- wFR

                -- _,pos = string.unpack("=f", content, pos) -- wRL
                -- _,pos = string.unpack("=f", content, pos) -- wRL
                -- _,pos = string.unpack("=f", content, pos) -- wRL
                -- _,pos = string.unpack("=f", content, pos) -- wRL
                -- _,pos = string.unpack("=f", content, pos) -- wRR
                -- _,pos = string.unpack("=f", content, pos) -- wRR
                -- _,pos = string.unpack("=f", content, pos) -- wRR
                -- _,pos = string.unpack("=f", content, pos) -- wRR

                -- _,pos = string.unpack("=f", content, pos) -- suspFL
                -- _,pos = string.unpack("=f", content, pos) -- suspFL
                -- _,pos = string.unpack("=f", content, pos) -- suspFL
                -- _,pos = string.unpack("=f", content, pos) -- suspFL
                -- _,pos = string.unpack("=f", content, pos) -- suspFR
                -- _,pos = string.unpack("=f", content, pos) -- suspFR
                -- _,pos = string.unpack("=f", content, pos) -- suspFR
                -- _,pos = string.unpack("=f", content, pos) -- suspFR

                -- _,pos = string.unpack("=f", content, pos) -- suspRL
                -- _,pos = string.unpack("=f", content, pos) -- suspRL
                -- _,pos = string.unpack("=f", content, pos) -- suspRL
                -- _,pos = string.unpack("=f", content, pos) -- suspRL
                -- _,pos = string.unpack("=f", content, pos) -- suspRR
                -- _,pos = string.unpack("=f", content, pos) -- suspRR
                -- _,pos = string.unpack("=f", content, pos) -- suspRR
                -- _,pos = string.unpack("=f", content, pos) -- suspRR
            end

            -- ac.perfEnd('load fast_lane')

            return ghtime, ghdate
        end
    end
    -- ac.debug("ghtime", ghtime)
    -- ac.debug("ghdaze", ghdate)
    return "", ""
end






local first = true
local function LoadSectionsIni()
    -- [SECTION_0]
    -- IN=0.152
    -- OUT=0.190
    -- TEXT=T1
    table.clear(Sects)
    if not io.fileExists(sectINI) then
        ac.debug('sectINI not found:', sectINI)
        if first then
            first=false
        else
            ui.toast(ui.Icons.AppWindow, 'sections.ini not found:'..sectINI)
        end
    else
        local i = 0
        local j = 0
        local sectName = "SECTION_"..i
        local sectText = readACConfig(sectINI, sectName, "TEXT", "")
        local lastsectText = ""
        while sectText ~= "" do
            local sectIN = tonumber ( readACConfig(sectINI, sectName, "IN", "-1") )
            local sectOUT = tonumber ( readACConfig(sectINI, sectName, "OUT", "-1") )
            if sectIN>-1 and sectOUT>-1 then
                --ac.debug('a ' .. j, sectText)
                if lastsectText == sectText then
                    Sects[j-1][2] = sectOUT
                else
                    if j>0 and Sects[0][0] == sectText then
                        Sects[0][1] = sectIN
                    else
                        local c = sectIN + (sectOUT-sectIN)/2
                        if sectOUT<sectIN then c = sectIN + (sectIN-sectOUT)/2 end
                        local sectCenter = ac.trackProgressToWorldCoordinate(c)
                        sectCenter =        vec3(sectCenter.x,sectCenter.y  ,sectCenter.z)
                        local sectCenter2 = vec3(sectCenter.x,sectCenter.y+2,sectCenter.z)
                        local sectCenter3 = vec3(sectCenter.x,sectCenter.y+3,sectCenter.z)
                        table.insert(Sects, j, {[0]=sectText, [1]=sectIN, [2]=sectOUT, [3]=sectCenter, [4]=sectCenter2, [5]=sectCenter3, [6]=c})
                        -- table.insert(Sects, j, {[0]=sectText, [1]=sectIN, [2]=sectOUT})
                        j=j+1
                        lastsectText = sectText
                    end
                end
            end
            i=i+1
            sectName = "SECTION_"..i
            sectText = readACConfig(sectINI, sectName, "TEXT", "")
        end
        -- make sure its sorted
        table.sort(Sects, function (a, b) return a[1] < b[1] end)
        if first then
            first=false
        else
            ui.toast(ui.Icons.AppWindow, 'sections.ini Loaded!')
        end
    end
end


function DrawCornerNames(dt, splinePosition)
    if #Sects>0 then
        local currPos = ac.getCameraPosition()
        -- local currPos = ac.trackProgressToWorldCoordinate(splinePosition)
        -- local MAX_TRACKNAME_DISTANCE = 500.0
        -- for i = 1, #Sects do
        --     if currSect~=i then
        --         local d = currPos:distance(Sects[i][3])
        --         local sz = math.min(3, math.max(1,100/d))
        --         if d < MAX_TRACKNAME_DISTANCE then
        --             if d>5.0 then
        --             render.debugLine(Sects[i][4], Sects[i][3], rgbm.colors.white)
        --             end
        --             render.debugText(Sects[i][5], Sects[i][0], rgbm.colors.white, sz, render.FontAlign.Center)
        --             render.setBlendMode(4)
        --         end
        --     end
        -- end

        if prevSect then
            local d = currPos:distance(prevSect[3])
            local sz = math.min(3, math.max(1*fntSize/22,100/d))
            --ac.debug("sz", sz)
            if d>20.0 then
            render.debugLine(prevSect[4], prevSect[3], rgbm.colors.white)
            end
            render.debugText(prevSect[5], prevSect[0], rgbm.colors.white, sz, render.FontAlign.Center)
            render.setBlendMode(4)
            render.setDepthMode(4)
        end
        if nextSect then
            local d = currPos:distance(nextSect[3])
            local sz = math.min(3, math.max(1*fntSize/22,100/d))
            --ac.debug("sz", sz)
            if d>20.0 then
            render.debugLine(nextSect[4], nextSect[3], rgbm.colors.white)
            end
            render.debugText(nextSect[5], nextSect[0], rgbm.colors.white, sz, render.FontAlign.Center)
            render.setBlendMode(4)
            render.setDepthMode(4)
        end
        if currSect>-1 then
            local d = currPos:distance(Sects[currSect][3])
            local sz = math.min(3, math.max(1*fntSize/22,100/d))
            --ac.debug("sz", sz)
            if d>20.0 then
            render.debugLine(Sects[currSect][4], Sects[currSect][3], rgbm.colors.white)
            end
            -- ac.debug("ac.", sim.whiteReferencePoint)
            if sim.whiteReferencePoint>1 then
            render.debugText(Sects[currSect][5], Sects[currSect][0], rgbCurrentSection*exposure*3, sz, render.FontAlign.Center)
            else
            render.debugText(Sects[currSect][5], Sects[currSect][0], rgbCurrentSection*exposure*100, sz, render.FontAlign.Center)
            end
            render.setBlendMode(4)
            render.setDepthMode(4)
        end
    end
end



local function CheckIfInsideINOUT(pin, pout, splinepos)
    if pout<pin then
        -- from end of track, wrapping over to start of track/next lap
        if splinepos>pin then
            return true
        elseif splinepos<pout then
            return true
        end
    else
        -- normal section has to be inside those two bounds
        if splinepos>=pin and splinepos<pout then
            return true
        end
    end
    return false
end

local function CheckIfInsideINOUTsimple(pin, pout, splinepos)
    -------------oldversion----------------
    if pout<=pin or pout-pin==1.0 then
        -- from end of track, wrapping over to start of track/next lap
        if splinepos>=pin then return true
        elseif splinepos<=pout then return true end
    else
        -- normal section has to be inside those two bounds
        if splinepos<=pout then return true end
    end
    return false
end

local function CheckCurrentSection()
    if car ~= nil then
        local cSpline = car.splinePosition
        local lastS = -1
        currSect = -1
        prevSect = nil
        nextSect = nil
        for k,v in pairs(Sects) do
            if CheckIfInsideINOUT(v[1], v[2], cSpline) then
                if k+1<=#Sects then
                    nextSect = Sects[k+1]
                else
                    nextSect = Sects[0]
                end
                currSect = k
                break
            end
            if cSpline<v[1] and cSpline<v[2] then
                -- currSect = k
                break
            end
            lastS = k
        end
        -- ac.debug("lastS", lastS)
        -- ac.debug("currSect", currSect)
        if currSect>=0 then
            if lastS>=0 then
                prevSect = Sects[lastS]
            else
                currSect = 0
                prevSect = Sects[#Sects]
            end
            if currSect+1>#Sects then
                nextSect = Sects[0]
            else
                nextSect = Sects[currSect+1]
            end
        else
            if lastS==-1 then
                prevSect = Sects[#Sects]
            else
                prevSect = Sects[lastS]
            end
            if lastS+1<=#Sects then
                nextSect=Sects[lastS+1]
            else
                nextSect=Sects[0]
            end
        end
    end
end



local function FFBdisable()
    if lastFFB==0.0 then
        ffbTimer = 0.85
        lastFFB = car.ffbMultiplier
        ac.setFFBMultiplier(0)
    end
end




local function SetBack()
  if car ~= nil then
    local cSpline = car.splinePosition
    p1 = ac.trackProgressToWorldCoordinate(cSpline)
    p3 = p1
    p2 = p3
    dist = 0.0
    while dist<=jumpdist and dist<sim.trackLengthM do
      cSpline = cSpline - 0.0001
      if cSpline<0.0 then
        cSpline = cSpline + 1.0
      end
      p3 = p2
      p2 = ac.trackProgressToWorldCoordinate(cSpline)
      dist = p1:distance(p2)
    end
    if cSpline>0.0 then
        FFBdisable()
        physics.setCarPosition(0, p2, vec3(p2.x-p3.x,p2.y-p3.y,p2.z-p3.z))
        --physics.setCarPosition(0, pos, vec3(1,0,0))
    end
  end
end


local function SetForw()
  if car ~= nil then
    local cSpline = car.splinePosition --# -0.001
    if cSpline<0.0 then
      cSpline=0.999
    end
    p1 = ac.trackProgressToWorldCoordinate(cSpline)
    p3 = p1
    p2 = p3
    dist = 0.0
    while dist<=jumpdist and dist<sim.trackLengthM do
      cSpline = cSpline + 0.0001
      if cSpline>1.0 then
        cSpline = 0.0
      end
      p3 = p2
      p2 = ac.trackProgressToWorldCoordinate(cSpline)
      dist = p1:distance(p2)
    end
    if cSpline>0.0 then
        FFBdisable()
        physics.setCarPosition(0, p2, vec3(p3.x-p2.x,p3.y-p2.y,p3.z-p2.z))
        --physics.setCarPosition(0, pos, vec3(1,0,0))
    end
  end
end



local function Reset()
    FFBdisable()
    ac.resetCar()
end

local function SetPits()
    FFBdisable()
    physics.teleportCarTo(0, ac.SpawnSet.Pits)
end


local function settexts()
  if WheelHidden==1 then
    textsteer = 'Show\nstwheel'
  else
    textsteer = 'Hide\nstwheel'
  end
  if DriverHidden==1 then
    textdriver = 'Show\ndriver'
  else
    textdriver = 'Hide\ndriver'
  end
end
settexts()


local function ToggleSteeringWheel()
  if carMeshes~=nil then
    if WheelHidden==0 then
      WheelHidden = 1
      carMeshes:setVisible(false)
      writeACConfig(vidini, 'ASSETTOCORSA', 'HIDE_STEER', '1')
    else
      WheelHidden = 0
      carMeshes:setVisible(true)
      writeACConfig(vidini, 'ASSETTOCORSA', 'HIDE_STEER', '0')
    end
  end
  settexts()
end

local function ToggleDriver()
  if car.isDriverVisible then
    DriverHidden = 1
    ac.setDriverVisible(0, false)
    writeACConfig(acini, 'DRIVER', 'HIDE', '1')
  else
    DriverHidden = 0
    ac.setDriverVisible(0, true)
    writeACConfig(acini, 'DRIVER', 'HIDE', '0')
  end
  settexts()
end



---------------------------------------------------------------------------------------------

local function DrawTextWithShadows(s, fntsize, algn, xy1, xy2, wrap, col)
    local xy3 = xy1
    local xy4 = xy2
    xy3.x=xy3.x+1
    xy3.y=xy3.y+1
    ui.setCursorX(xy1.x)
    ui.setCursorY(xy1.y)
    ui.dwriteTextAligned( s, fntsize, algn, xy3, xy4, wrap, rgbm.colors.black )
    xy3.x=xy3.x-2
    xy3.y=xy3.y-2
    -- ui.setCursorX(xy1.x)
    -- ui.setCursorY(xy1.y)
    -- ui.dwriteTextAligned( s, fntsize, algn, xy3, xy4, wrap, rgbm.colors.black )

    ui.setCursorX(xy1.x)
    ui.setCursorY(xy1.y)
    ui.dwriteTextAligned( s, fntsize, algn, xy1, xy2, wrap, col )
end

local function DrawTextACWithShadows(s, fntsize, xy1, xy2, col)
    ui.setCursorX(0)
    ui.setCursorY(0)
    local xy3 = xy1
    local xy4 = xy2
    xy3.x=xy3.x-2
    xy3.y=xy3.y-2
    ui.setCursorX(xy1.x)
    ui.setCursorY(xy1.y)
    ui.acText(s, vec2(math.floor(fntsize/2),fntsize), 0, rgbm.colors.black, 0, true)
    xy3.x=xy3.x-1
    xy3.y=xy3.y-1
    ui.setCursorX(xy1.x)
    ui.setCursorY(xy1.y)
    ui.acText(s, vec2(math.floor(fntsize/2),fntsize), 0, rgbm.colors.black, 0, true)
    ui.setCursorX(xy1.x)
    ui.setCursorY(xy1.y)
    ui.acText(s, vec2(math.floor(fntsize/2),fntsize), 0, col, 0, true)
    -- ui.dwriteTextAligned( s, fntsize, algn, xy1, xy2, wrap, col )
end



local function JumpSection(cSpline)
    if car ~= nil then
        local p1 = ac.trackProgressToWorldCoordinate(cSpline)
        local p3 = p1
        local p2 = p3
        local dist = 0.0
        local cSpline2 = cSpline

        while dist<=1 and dist<sim.trackLengthM do
            cSpline2 = cSpline2 + 0.001
            if cSpline2>1.0 then
                cSpline2 = 0.0
            end
            p3 = p2
            p2 = ac.trackProgressToWorldCoordinate(cSpline2)
            dist = p1:distance(p2)
        end

        if dist>0.0 then
            -- set new car position
            local direction = vec3(p3.x-p2.x,p3.y-p2.y,p3.z-p2.z)
            physics.setCarPosition(0, p2, direction)
        end
    end
end




local function pushCar(dt)
    local passivePush = pushForce * car.mass * dt * 100 * car.gas
    physics.addForce(0, vec3(0, 0, 0), true, vec3(0, 0, passivePush), true)
end





-- local aiFolder = ac.getFolder(ac.FolderID.CurrentTrackLayout)..'\\ai\\'
local aiFolder = ac.getFolder(ac.FolderID.CurrentTrackLayout)..'/ai/'
local dataFolder = ac.getFolder(ac.FolderID.CurrentTrackLayout)..'/data/'
local lastSelected = readACConfig(appini, 'USERSETTINGS', 'AILINE_FILE' , 'fast_lane.ai')
local splineFilename = aiFolder .. 'fast_lane.ai'
local availableSplines = {}


local function GetAvailableSplines()
    availableSplines = io.scanDir(aiFolder, '*.ai')
    -- ac.debug("availableSplines1", availableSplines)
    local availableSplines2 = io.scanDir(dataFolder, '*.ai')
    for i,v in ipairs(availableSplines) do
        availableSplines[i] = aiFolder .. availableSplines[i]
        if lastSelected==availableSplines[i] then
            splineFilename = aiFolder .. availableSplines[i]
        end
    end
    for i,v in ipairs(availableSplines2) do
        table.insert(availableSplines, dataFolder .. v)
        if lastSelected==availableSplines2[i] then
            splineFilename = dataFolder .. availableSplines2[i]
        end
    end
    if string.lower(io.getFileName(splineFilename)) == "fast_lane.ai"
        and ac.hasTrackSpline() then
        CreateBorders()
    else
        ReadAILINE(splineFilename)
    end
end


if ac.getPatchVersionCode()>=3044 then
    GetAvailableSplines()
end


local function tablecontains(t, s)
    for i=0, #t do
        if t[i][0] == s then
            return true
        end
    end
    return false
end




local function DrawGhost(dt, cSpline)
    if #BGhostIdealC>0 then
        local dx = cSpline   -- car.speedMs/1000 --  - math.abs(ghtime-car.estimatedLapTimeMs)/ghtime
        local stepswanted = math.min(#BGhostIdealC, ai_renderlength + leadinCount )
        local stepsdone = 0
        local currID = math.floor((dx * #BGhostIdealC - leadinCount + partlen + 1))
        if currID<=0 then
            currID = #BGhostIdealC + currID
        end
        currID = currID - ((currID % partlen))
        local nextID = currID + partlen
        local fadeDist = 0.0

        render.setBlendMode(4)
        render.setDepthMode(4)
        -- render.setCullMode(9)

        while stepsdone<stepswanted do
            if currID<=0 then
                currID = 1
                nextID = currID + partlen*AIskipVar
            end
            if currID>#BGhostIdealC then
                currID = currID - #BGhostIdealC
                currID = currID - ((currID % partlen))
                nextID = currID + partlen*AIskipVar
            end
            if nextID>#BGhostIdealC then
                currID = 1 --#BGhostIdealC --partlen
                nextID = partlen
            end
            if stepsdone<=10 and fadeDist<=1.0 then
                fadeDist = fadeDist+0.1
            elseif stepsdone>stepswanted-10 then
                fadeDist = fadeDist-0.1
            end

            if not bDrawWalls then
                --render.line
                render.debugLine(BGhostIdealL[currID]*glowmultB*10, BGhostIdealL[nextID]*glowmultB*10, rgbBorder * exposure)
                render.debugLine(BGhostIdealR[currID]*glowmultB*10, BGhostIdealR[nextID]*glowmultB*10, rgbBorder * exposure)
            else
                if nextID <= #BGhostIdealC then
                    render.glSetColor(rgbBorder*glowmultB * exposure*10 * fadeDist)
                    if idealTexture==14 then
                    -- render.quad(BGhostIdealL[nextID], BGhostIdealR[nextID], BGhostIdealR[currID], BGhostIdealL[currID], rgbBorder*glowmultB * exposure*10, texAIline)
                    render.debugArrow(BGhostIdealC[currID], BGhostIdealC[nextID], 0.25, rgbBorder*glowmultB * exposure*5 * fadeDist)
                    -- render.quad(BGhostIdealL[nextID], BGhostIdealR[nextID], BGhostIdealR[currID], BGhostIdealL[currID], color, texAIline)

                    else
                    render.quad(BGhostIdealL[currID], BGhostIdealR[currID], BGhostIdealR[nextID], BGhostIdealL[nextID], rgbBorder*glowmultB * exposure*10 * fadeDist, texAIline)
                    end
                    --render.quad(BGhostIdealR[currID], BGhostIdealR[currID], BGhostIdealR[nextID], BGhostIdealL[nextID], rgbBorder*glowmultB * exposure, texAIline)
                end
            end
            stepsdone = stepsdone + partlen
            currID = currID + partlen
            nextID = currID + partlen
        end
    end
end




local function GetIDdist(fromID, toID)
    local res = toID-fromID
    if fromID>toID then
        res = toID + math.abs(res)
    end
    return res
end



local shader = {
    p1 = vec3(), p2 = vec3(), p3 = vec3(), p4 = vec3(),
    directValuesExchange = true,
    cacheKey = 1,
    textures = {txInput1 = ''},
    -- textures = {txIcon = '', txOverlay = 'color::#00000000'},
    values = {gColor = rgb(), gAlpha = 1},
    shader = [[
        float4 main(PS_IN pin) {
            float4 in1 = txInput1.Sample(samLinear, pin.Tex);
            //in1 -= txInput1.SampleBias(samAnisotropic, pin.Tex, -1);
            return in1 * gColor;
        }
    ]]
    -- float4 in1 = txInput1.Sample(samLinear, pin.Tex);

    -- float4 in1 = txInput1.Sample(samLinearSimple, pin.Tex);
    --samAnisotropic
    --samPointClamp
    --samPoint
    --samLinearBorder0
    --samLinearClamp
    --samLinear
    --samLinearSimple

    -- shader = [[
    --   float4 main(PS_IN pin) {
    --     pin.Tex.x = 1 - pin.Tex.x;
    --     pin.Tex = pin.Tex * 1.8 - 0.4;
    --     float2 texNrm = pin.Tex * 2 - 1;
    --     float2 texRem = max(0, abs(texNrm) * 10 - 9);
    --     float texRemL = max(texRem.x, texRem.y); // length(texRem);
    --     if (texRemL > 3) discard;
    --     float4 tx = txIcon.SampleBias(samLinearBorder0, pin.Tex, -0.5);
    --     float4 txOv = txOverlay.SampleBias(samLinearBorder0, pin.Tex * 0.84 + 0.08, -0.5);
    --     if (any(abs(pin.Tex * 2 - 1) > 1)) tx = 0;
    --     tx = lerp(tx, txOv, txOv.w);
    --     float4 bg = float4(pow(max(0, gColor), USE_LINEAR_COLOR_SPACE ? 2.2 : 1), 1);
    --     bg.rgb = lerp(bg.rgb, tx.rgb, tx.w) * (3 * gWhiteRefPoint);
    --     bg.w = gAlpha * saturate((3 - texRemL) * 5);
    --     return pin.ApplyFog(bg);
    --   }
    -- ]]
}

local dc = shader

local function RENDERTex(BIdealLcurrID, BIdealRcurrID, BIdealRnextID, BIdealLnextID, color, tex)
    render.quad(BIdealLcurrID, BIdealRcurrID, BIdealRnextID, BIdealLnextID, color, texAIline)

    -- dc.p1:set(BIdealLcurrID)
    -- dc.p2:set(BIdealRcurrID)
    -- dc.p3:set(BIdealRnextID)
    -- dc.p4:set(BIdealLnextID)
    -- dc.textures.txInput1 = tex
    -- --dc.textures.txOverlay = tex
    -- dc.values.gColor = color --vec3(color.r, color.g, color.b)
    -- dc.values.gAlpha = 1 --color.mult -- math.lerpInvSat(BIdealLcurrID:distanceSquared(sim.cameraPosition), 20 ^ 2, (20 * 1.2) ^ 2)
    -- render.shaderedQuad(dc)

    -- render.mesh({
    --     mesh = ac.SimpleMesh.carCollider(focused.index, not isCollidersDebugOriginal),
    --     transform = focused.bodyTransform,
    --     textures = {},
    --     values = {},
    --     shader = [[float4 main(PS_IN pin) {
    --     float g = dot(normalize(pin.NormalW), normalize(pin.PosC));
    --     return float4(float3(saturate(-g), saturate(g), 1) * gWhiteRefPoint, pow(1 - abs(g), 2));
    --     }]]
    -- })
    -- render.shaderedQuad({
    --     --p1 = vec3(), p2 = vec3(), p3 = vec3(), p4 = vec3(),
    --     mesh = {},
    --     transform = {},
    --     textures = {cin=texAIline},
    --     values = {p1L=BIdealLcurrID, p1R=BIdealRcurrID, p2R=BIdealRnextID, p2L=BIdealLnextID, col=color},
    --     shader = [[
    --         float4 main(PS_IN pin) {
    --         return float4(pin.Tex.x, pin.Tex.y, 0.5, 0.5);
    --     }]]
    --     -- return float4 ( float3( saturate(-g), saturate(g), 1) * gWhiteRefPoint*0.5, pow(1 - abs(g), 2));
    --     -- return float4(float3(0.4,0.4,0.4), 0.5);
    -- })
end


local lineFadeLevelCurrent = 0
local lineFadeLevelTarget = 1
local lineFadeRedCurrent = 0
local lineFadeGreenCurrent = 1
local lineFadeRedTarget = 1
local lineFadeGreenTarget = 1

local lastRedID = -1
local lineFadeRedCurrentlast=0.0
local lineFadeGreenCurrentlast=0.0
local lineFadeDist = 0.0
local vecA = vec2(0, 0)
local vecB = vec2(0, 1)
local vecC = vec2(1, 1)
local vecD = vec2(1, 0)

local color = rgbm(0,1,0,glowmult)
-- local distanceFade = math.max(0, ((stepswanted-10)-stepsdone)/stepswanted)


local function DrawAILine(dt, cSpline)
    local stepswanted = math.min(#BIdealC, ai_renderlength + leadinCount)
    local stepsdone = 0
    local currID = math.floor((cSpline * #BLeft) - leadinCount + partlen+1)
    if currID<=0 then
        currID = #BLeft + currID
    end
    currID = currID - ((currID % partlen))
    local nextID = currID + partlen

    -- -- local stepswanted = ai_renderlength
    -- local stepswanted = math.min(#BIdealC, ai_renderlength + leadinCount)
    -- local stepsdone = 0
    -- local currID = math.floor((cSpline * #BLeft) - leadinCount + partlen+1)
    -- if currID<=0 then
    --     currID = #BLeft + currID
    -- end
    -- currID = currID - ((currID % partlen))
    -- local nextID = currID + partlen

    -- local stepswanted = ai_renderlength
    -- local stepsdone = 0
    -- local currID = math.floor((cSpline * #BLeft) - leadinCount)
    -- if currID<=0 then
    --     currID = #BLeft + currID
    -- end
    -- currID = currID - (currID % partlenAIline)
    -- local nextID = currID + partlenAIline



    -- -- Distance and turn angle (in degrees)
    local ucTurn2 = ac.getTrackUpcomingTurn(0)
    -- ucTurn = vec2( ucTurn2.x, math.abs(ucTurn2.y))
    --ucTurn = vec2( ucTurn2.x, math.abs(ucTurn2.y)*CUSTOM_MULT)
    ucTurn = vec2( ucTurn2.x, math.abs(ucTurn2.y))
    --ac.debug("ucTurn.x", ucTurn.x)

    -- ui.beginTonemapping()

    render.setBlendMode(4)
    render.setDepthMode(4)
    -- render.setBlendMode(1)
    -- render.setBlendMode(13)
    -- render.setCullMode(9)


    while stepsdone<stepswanted do
        if currID<=0 then
            currID = 1
            nextID = currID + partlen*AIskipVar
        end
        if currID>#BLeft then
            currID = currID - #BLeft
            currID = currID - ((currID % partlen))
            nextID = currID + partlen*AIskipVar
        end
        if nextID>#BLeft then
  --          currID = #BLeft - partlen*AIskipVar
            -- nextID = 1
            currID = #BLeft --partlen
            nextID = partlen
            -- nextID = 1
            -- ac.debug("currID", currID)
            -- ac.debug("nextID", nextID)
            -- nextID = currID + partlen*AIskipVar
        end

        -- start fade in
        if lineFadeDist<1.0 and stepsdone < partlen*AIskipVar*30 then
            lineFadeDist = lineFadeDist + 0.035
            if lineFadeDist>1.0 then
                lineFadeDist = 1.0
            end
        end

        -- end fade out
        if stepsdone+partlen*AIskipVar*10 > stepswanted and lineFadeDist>0.0
        then
            lineFadeDist = lineFadeDist - 0.15
            if lineFadeDist<0.0 then
                lineFadeDist = 0.0
            end
        end

        -- -- start fade in
        -- if lineFadeDist<1.0 and stepsdone < partlen*AIskipVar*20 then
        --     lineFadeDist = lineFadeDist + 0.05
        --     if lineFadeDist>1.0 then
        --         lineFadeDist = 1.0
        --     end
        -- end

        -- -- end fade out
        -- if stepsdone+partlen*AIskipVar*10 > stepswanted and lineFadeDist>0.0
        -- then
        --     lineFadeDist = lineFadeDist - 0.15
        --     if lineFadeDist<0.0 then
        --         lineFadeDist = 0.0
        --     end
        -- end

        if stepsdone>1 and currID>0 and currID<=#BLeft and nextID>0 and nextID<=#BLeft then
            if     ((ucTurn.y>=100 and ucTurn.x<2*car.speedKmh/25*1/CUSTOM_MULT*1)) then
                lineFadeLevelTarget = 8
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0
            elseif ((ucTurn.y>=80 and ucTurn.x<2*car.speedKmh/20*1/CUSTOM_MULT*1)) then
                lineFadeLevelTarget = 4
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0
            elseif ((ucTurn.y>=60 and ucTurn.x<2*car.speedKmh/17.5*1/CUSTOM_MULT*1)) then
                lineFadeLevelTarget = 2
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0
            elseif ((ucTurn.y>=40 and ucTurn.x+1<2*car.speedKmh/15*1/CUSTOM_MULT*1)) then
                lineFadeLevelTarget = 1
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0
            elseif ((ucTurn.y>=36.25 and ucTurn.x+2<2*car.speedKmh/10*1/CUSTOM_MULT*1)) then
                if bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.75
                end
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0.25
            elseif ((ucTurn.y>=32.5 and ucTurn.x+3<2*car.speedKmh/8*1/CUSTOM_MULT*1)) then
                if bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.5
                end
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0.5
            elseif ((ucTurn.y>=27.75 and ucTurn.x+4<2*car.speedKmh/6*1/CUSTOM_MULT*1)) then
                if bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.25
                end
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 0.75
            elseif ((ucTurn.y>=25 and ucTurn.x+5<2*car.speedKmh/4*1/CUSTOM_MULT*1)) then
                if bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.01
                end
                lineFadeRedTarget = 1
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=21.875 and ucTurn.x+5<2*car.speedKmh/3.5*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.8
                end
                lineFadeRedTarget = 0.875
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=18.75 and ucTurn.x+5<2*car.speedKmh/3*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.4
                end
                lineFadeRedTarget = 0.75
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=15.625 and ucTurn.x+5<2*car.speedKmh/2.5*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.2
                end
                lineFadeRedTarget = 0.675
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=12.5 and ucTurn.x+5<2*car.speedKmh/2*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.1
                end
                lineFadeRedTarget = 0.5
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=9.375 and ucTurn.x+5<2*car.speedKmh/1.5*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.05
                end
                lineFadeRedTarget = 0.375
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=6.25 and ucTurn.x+5<2*car.speedKmh/1*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.025
                end
                lineFadeRedTarget = 0.25
                lineFadeGreenTarget = 1
            elseif ((ucTurn.y>=3.125 and ucTurn.x+5<2*car.speedKmh/0.5*1/CUSTOM_MULT*1)) then
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0.0125
                end
                lineFadeRedTarget = 0.125
                lineFadeGreenTarget = 1
            else
                if not bAIonlyWhenNotYellow then
                    lineFadeLevelTarget = 0
                elseif bAIonlyWhenNotGreen then
                    lineFadeLevelTarget = 1
                else
                    lineFadeLevelTarget = 0
                end
                lineFadeRedTarget = 0
                lineFadeGreenTarget = 1
            end

            lineFadeLevelCurrent = 1
            if lineFadeLevelCurrent ~= lineFadeLevelTarget then
                if lineFadeLevelCurrent < lineFadeLevelTarget then
                    lineFadeLevelCurrent = lineFadeLevelCurrent + (lineFadeLevelTarget-lineFadeLevelCurrent)*(0.4/stepswanted)
                else
                    lineFadeLevelCurrent = lineFadeLevelCurrent + (lineFadeLevelTarget-lineFadeLevelCurrent)*(0.2/stepswanted)
                end
            end
            if lineFadeRedCurrent ~= lineFadeRedTarget then
                if lineFadeRedCurrent < lineFadeRedTarget then
                    lineFadeRedCurrent = lineFadeRedCurrent + (lineFadeRedTarget-lineFadeRedCurrent)*(0.4/stepswanted)
                else
                    lineFadeRedCurrent = lineFadeRedCurrent + (lineFadeRedTarget-lineFadeRedCurrent)*(0.2/stepswanted)
                end
            end
            if lineFadeGreenCurrent ~= lineFadeGreenTarget then
                if lineFadeGreenCurrent > lineFadeGreenTarget then
                    lineFadeGreenCurrent = lineFadeGreenCurrent + (lineFadeGreenTarget-lineFadeGreenCurrent)*(0.4/stepswanted)
                else
                    lineFadeGreenCurrent = lineFadeGreenCurrent + (lineFadeGreenTarget-lineFadeGreenCurrent)*(0.2/stepswanted)
                end
            end
            if not bAIonlyWhenNotGreen and lineFadeGreenCurrent>0 then
                lineFadeLevelCurrent=1-lineFadeGreenCurrent
            end

            if stepswanted+10>=#BLeft then
                -- draw without fading when do it all
                -- distanceFade=1
            end
            -- if not bAIonlyWhenNotYellow and lineFadeRedCurrent<0.5 then
            --     lineFadeLevelCurrent=1-lineFadeRedCurrent
            -- end

            if (currID % (AIskipVar*partlen) == 0) then
                if bAImonocolor then
                    color = rgbm(rgbSingleColor.r*glowmult*lineFadeDist  , rgbSingleColor.g*glowmult*lineFadeDist    ,    rgbSingleColor.b*glowmult,    lineFadeDist*exposure*glowmult*10)
                else
                    color = rgbm(lineFadeRedCurrent*glowmult*lineFadeDist, lineFadeGreenCurrent*glowmult*lineFadeDist, 0,          lineFadeLevelCurrent*lineFadeDist*exposure*glowmult*10)
                end
                if bAIideal and stepsdone>0 then                --render.glSetColor(color)
                    -- render.quad(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color, texAIline)
                    -- render.on('main.root.transparent', function()
                    -- blendMode = render.BlendMode.AlphaBlend,
                    -- depthMode = render.DepthMode.Off,
                    if idealTexture==14 then
                        render.debugArrow(BIdealC[currID], BIdealC[nextID], 0.25, color/4)
                    else
                        RENDERTex(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color, texAIline)
                    end

                end
            end
        end

        -- if bDriveHint and
        --     --stepsdone-leadinCount+10 >= ucTurn2.x and
        --     --stepsdone-leadinCount+10 <  ucTurn2.x +(AIskipVar*partlen) then
        --     stepsdone-leadinCount >= 10 and
        --     stepsdone-leadinCount <  10 +(AIskipVar*partlen)
        -- then
        --     local pC1 = car.position + car.look*10   + vUp*0.2
        --     local pC2 = car.position + car.look*11   + vUp*0.2
        --     render.quad(pC1 + car.side + vUp*0.3,
        --                 pC1 - car.side + vUp*0.3,
        --                 pC2 - car.side + vUp*0.75+vUp*(lineFadeRedCurrent-lineFadeGreenCurrent/2)/2,
        --                 pC2 + car.side + vUp*0.75+vUp*(lineFadeRedCurrent-lineFadeGreenCurrent/2)/2, color*2, texAIline)
        -- end

        if  ucTurn.x > 10 and ucTurn.x<300 and
            stepsdone-leadinCount >= 10
            and
            stepsdone-leadinCount >= ucTurn.x
            and
            stepsdone-leadinCount <  ucTurn.x + partlen
        then
            if lastRedID==-1 or currID <= partlen+1 then
                lastRedID = currID
            else
                if not
                (currID >= lastRedID-partlen and
                    currID <= lastRedID)
                then
                    lastRedID = currID
                end
            end
        end

        if bCornerArrow and lastRedID>0 and currID>=lastRedID and currID<lastRedID+partlen and stepsdone-leadinCount > 5 then
            render.debugArrow(BIdealC[currID]+vUp*2, BIdealC[currID], 0.25, color/sim.whiteReferencePoint*2)
            -- render.debugLine(BLeft[currID]-vUp*0.2, BRight[currID]-vUp*0.2, color*10)
        end

        if bAIborders then
            color = rgbm(rgbBorder.r*glowmultB, rgbBorder.g*glowmultB, rgbBorder.b*glowmultB, exposure*glowmultB*10)
            render.quad(BLeft [currID], BLeft[nextID],
                        BLeft2[nextID], BLeft2[currID],
                        lineFadeDist * color, texBorder)
            render.quad(BRight [currID], BRight[nextID],
                        BRight2[nextID], BRight2[currID],
                        lineFadeDist * color, texBorder)
        end

        -- debug stuff -- --
        -- if  bDebugText and
        --     stepsdone-leadinCount >= 10 and
        --     stepsdone-leadinCount <  10 +(AIskipVar*partlen)
        -- then
        --     render.debugText(car.position + car.look*10   + vUp*0.3+vUp*4,
        --         tostring("Turn dist       "..math.round(ucTurn.x,1)).."\n"..
        --         tostring("Turn angl (abs) "..math.round(math.abs(ucTurn.y),1)).."\n"..
        --         tostring("mps             "..math.round(car.speedMs,1)).."\n",
        --         rgbm.colors.white, 2, render.FontAlign.Left)
        --     render.setBlendMode(4)
        --     render.setDepthMode(4)
        -- end
        -- debug stuff -- --


        stepsdone = stepsdone + partlen
        currID = currID       + partlen
        nextID = currID       + partlen
    end
    -- ui.endTonemapping(1, 0, true)

end

-------------------------------------------------------------------------


local function DrawAILineOrigOrig(dt, cSpline)
    local stepswanted = math.min(#BIdealC, ai_renderlength + leadinCount)
    local stepsdone = 0
    local currID = math.floor((cSpline * #BLeft) - leadinCount + partlen+1)
    if currID<=0 then
        currID = #BLeft + currID
    end
    currID = currID - ((currID % partlen))
    local nextID = currID + partlen

    -- render.setBlendMode(13)
    render.setBlendMode(4)
    -- render.setBlendMode(render.BlendMode.AlphaBlend)
    render.setDepthMode(4)

    local rgb = 1
    local gas = 0.0
    local brake = 0.0

    local ucTurn2 = ac.getTrackUpcomingTurn(0)
    ucTurn = vec2(ucTurn2.x, math.abs(ucTurn2.y))

    lineFadeDist = 0
    lineFadeRedCurrent = lineFadeRedCurrentlast
    lineFadeGreenCurrent = lineFadeGreenCurrentlast

    while stepsdone<stepswanted do
        if currID<=0 then
            currID = 1
            nextID = currID + partlen*AIskipVar
        end
        if currID>#BLeft then
            currID = currID - #BLeft
            currID = currID - ((currID % partlen))
            nextID = currID + partlen*AIskipVar
        end
        if nextID>=#BLeft then
            -- nextID = nextID - #BLeft
            currID = #BLeft --partlen
            nextID = partlen
        end

        if stepsdone>1 and currID>0 and currID<#BLeft and nextID>0 and nextID<#BLeft
        then
            local diff = math.max(-1, math.min(1, math.deg(BDir[nextID]-BDir[currID])))
            --ac.debug(tostring(stepsdone), diff)
            diff = math.max(-1, math.min(1, math.deg(BDir[nextID]-BDir[currID])/0.25/CUSTOM_MULT))
            diff=math.abs(diff)

                -- start fade in
            if lineFadeDist<1.0 and stepsdone < partlen*AIskipVar*20 then
                lineFadeDist = lineFadeDist + 0.05
                if lineFadeDist>1.0 then
                    lineFadeDist = 1.0
                end
            end

            -- end fade out
            if stepsdone+partlen*AIskipVar*10 > stepswanted and lineFadeDist>0.0
            then
                lineFadeDist = lineFadeDist - 0.15
                if lineFadeDist<0.0 then
                    lineFadeDist = 0.0
                end
            end


            if iDoColorFade~=2 then
                if  (ucTurn.x > 0 and ucTurn.x < 300)
                    or
                    (ucTurn.x < 300 and lastRedID>-1
                    and (currID < lastRedID+car.speedMs))
                then
                    -- handling distance (& angle a bit) for next turn -- --

                    -- if  bDebugText and
                    -- stepsdone-leadinCount >= 10 and
                    -- stepsdone-leadinCount <  10 +(AIskipVar*partlen)
                    -- then render.debugText(car.position + car.look*10   + vUp*0.3+vUp*5,
                    --     "distance", rgbm.colors.white, 2, 0) render.setDepthMode(4) render.setBlendMode(4) end

                    if     currID >= lastRedID-car.speedMs*1/CUSTOM_MULT and
                        currID <  lastRedID+car.speedMs*1/CUSTOM_MULT
                            and ((ucTurn.y>car.speedMs*CUSTOM_MULT/5))
                    then
                        -- if stepsdone > partlen*AIskipVar*20 then
                        -- lineFadeDist=math.clamp(lineFadeDist+0.1,0,1) end
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)

                    elseif currID >= lastRedID-car.speedMs*1/CUSTOM_MULT*2 and
                        currID <  lastRedID-car.speedMs*1/CUSTOM_MULT
                            and ((ucTurn.y>car.speedMs*CUSTOM_MULT/10)
                            or
                            (ucTurn.y>car.speedMs/2))
                    then
                        if bAIonlyWhenNotYellow then
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                        else
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                        end
                        -- if stepsdone > partlen*AIskipVar*20 then
                        -- if true then
                        --     if not bAIonlyWhenNotYellow then
                        --         lineFadeDist=math.clamp(lineFadeDist-0.1,0,1)
                        --     else
                        --         lineFadeDist=math.clamp(lineFadeDist+0.1,0,1)
                        --     end
                        -- end
                    else
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                        if bAIonlyWhenNotGreen then
                            lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                        else
                            --if stepsdone > partlen*AIskipVar*20 then
                            -- if true then
                            --     lineFadeDist=math.clamp(lineFadeDist-0.1,0,1)
                            -- end
                            lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                        end
                    -- else
                    --     -- color = rgbm(0,rgb,0,glowmult/4)
                    --     if stepsdone > partlen*AIskipVar*20 then
                    --         -- lineFadeDist=math.clamp(lineFadeDist+0.1,0,1)
                    --       end
                    --     lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                    --     if bAIonlyWhenNotGreen then
                    --         lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                    --     else
                    --         lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                    --     end
                    end

                else

                    -- if  bDebugText and
                    -- stepsdone-leadinCount >= 10 and
                    -- stepsdone-leadinCount <  10 +(AIskipVar*partlen)
                    -- then render.debugText(car.position + car.look*10   + vUp*0.3+vUp*5,
                    --     "angle", rgbm.colors.white, 2, 0) render.setDepthMode(4) render.setBlendMode(4) end


                    -- -- handling steering angle for next turn -- --
                    -- -- handling original ai line gas+throttle -- --
                    -- gas = BGas[currID]
                    -- brake = BBrake[currID]
                    if
                        BGas[currID]<=0.1 or BBrake[currID]>=0.001
                        or
                        (ucTurn.x==0 and ucTurn.y*CUSTOM_MULT*0.25>car.speedMs*1/CUSTOM_MULT)
                    then
                        -- if stepsdone > partlen*AIskipVar*20 then
                        --     lineFadeDist=math.clamp(lineFadeDist+0.1,0,1)
                        -- end
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                    elseif
                        ((BGas[currID]<=0.0) and not (BGas[currID]==0.0 and BBrake[currID]==0.0))
                        or
                        (ucTurn.x==0 and ucTurn.y*CUSTOM_MULT*0.5>car.speedMs*1/CUSTOM_MULT)
                    then
                        if bAIonlyWhenNotYellow then
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                        else
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                        end
                        -- if true then
                        -- -- if stepsdone > partlen*AIskipVar*20 then
                        --     if not bAIonlyWhenNotYellow then
                        --         lineFadeDist=math.clamp(lineFadeDist-0.1,0,1)
                        --     else
                        --         lineFadeDist=math.clamp(lineFadeDist+0.1,0,1)
                        --     end
                        -- end
                    else
                        lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                        if bAIonlyWhenNotGreen then
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                        else
                        lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                        end
                        -- if true then
                        -- -- if stepsdone > partlen*AIskipVar*20 then
                        --     if not bAIonlyWhenNotGreen then
                        --         lineFadeDist=math.clamp(lineFadeDist-0.1,0,1)
                        --     else
                        --         lineFadeDist=math.clamp(lineFadeDist+0.1,0,1)
                        --     end
                        -- end
                    end
                end  -- if uturn.x>0
            end

            if bAImonocolor then
                color = rgbm(rgbSingleColor.r*glowmult, rgbSingleColor.g*glowmult, rgbSingleColor.b*glowmult, exposure*glowmult*10)
            else
                color = rgbm(lineFadeRedCurrent*glowmult, lineFadeGreenCurrent*glowmult, 0, exposure*glowmult*10)
            end

            if bAIideal and (currID % (AIskipVar*partlen) == 0) then
                --render.quad(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color*lineFadeDist, texAIline)
                if iDoColorFade==2 then
                    color = rgbm((diff)*glowmult, (1-diff)*glowmult, 0, exposure*glowmult*10)
                end
                -- if diff>0 then
                --     diff=math.abs(diff)
                --     color = rgbm((0.5-diff)*glowmult, (0.5+diff)*glowmult, 0, exposure*glowmult*10)
                -- else
                --     diff=math.abs(diff)
                --     color = rgbm((0.5+diff)*glowmult, (0.5-diff)*glowmult, 0, exposure*glowmult*10)
                -- end
                if idealTexture==14 then
                    render.debugArrow(BIdealC[currID], BIdealC[nextID], 0.25, color*lineFadeDist/5)
                else
                    RENDERTex(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color*lineFadeDist, texAIline)
                end
            end

            if  ucTurn.x > 10 and ucTurn.x<300 and
                stepsdone-leadinCount >= 10
                and
                stepsdone-leadinCount >= ucTurn.x
                and
                stepsdone-leadinCount <  ucTurn.x + partlen
            then
                if lastRedID==-1 or currID <= partlen+1 then
                    lastRedID = currID
                else
                    if not
                    (currID >= lastRedID-partlen and
                     currID <= lastRedID)
                    then
                        lastRedID = currID
                    end
                end
            end

            -- draw borders
            if bAIborders then
                color = rgbm(rgbBorder.r*glowmultB, rgbBorder.g*glowmultB, rgbBorder.b*glowmultB, exposure*glowmultB*10)
                render.quad(BLeft [currID], BLeft[nextID],
                            BLeft2[nextID], BLeft2[currID],
                            lineFadeDist*color, texBorder)
                render.quad(BRight [currID], BRight[nextID],
                            BRight2[nextID], BRight2[currID],
                            lineFadeDist*color, texBorder)
            end

            if bCornerArrow and lastRedID>0 and currID>=lastRedID and currID<lastRedID+partlen and stepsdone-leadinCount > 5 then
                render.debugArrow(BIdealC[currID]+vUp*2, BIdealC[currID], 0.25, color/sim.whiteReferencePoint*2)
            end



            -- if  bDriveHint and
            --     stepsdone-leadinCount >= 5 and
            --     stepsdone-leadinCount <  5+partlen*AIskipVar
            --     and currID>0 and currID<=#BLeft and nextID>0 and nextID<=#BLeft
            -- then
            --     local pC1 = car.position + car.look*10   + vUp*0.2
            --     local pC2 = car.position + car.look*11   + vUp*0.2
            --     render.quad(pC1 + car.side + vUp*0.3,
            --                 pC1 - car.side + vUp*0.3,
            --                 pC2 - car.side + vUp*0.75+vUp*(lineFadeRedCurrent-lineFadeGreenCurrent/2)/2,
            --                 pC2 + car.side + vUp*0.75+vUp*(lineFadeRedCurrent-lineFadeGreenCurrent/2)/2, color*2, texAIline)
            -- end

            -- -- debug stuff -- --
            -- if  bDebugText and
            -- stepsdone-leadinCount >= 10 and
            -- stepsdone-leadinCount <  10 +(AIskipVar*partlen)
            -- then
            --     render.debugText(car.position + car.look*10   + vUp*0.3+vUp*4,
            --         tostring("Turn dist       "..math.round(ucTurn.x,1)).."\n"..
            --         tostring("Turn angl (abs) "..math.round(math.abs(ucTurn.y),1)).."\n"..
            --         tostring("mps             "..math.round(car.speedMs,1)).."\n",
            --         rgbm.colors.white, 2, render.FontAlign.Left)
            --     render.setBlendMode(4)
            --     render.setDepthMode(4)
            -- end
            -- -- debug stuff -- --

        end
        stepsdone = stepsdone + partlen
        currID    = currID    + partlen
        nextID    = currID    + partlen

    end
    -- ac.debug("1 stepswanted", stepswanted)
    -- ac.debug("2 stepsdone", stepsdone)
    -- ac.debug("lastRedID", lastRedID)
    -- ac.debug("#ideal", #BIdealC)
end


------------------------------------------------------------------------------------------

local function DrawAILineOrig(dt, cSpline)
    local stepswanted = ai_renderlength
    local stepsdone = 0
    local currID = math.floor((cSpline * #BLeft) - leadinCount)
    if currID<=0 then
        currID = #BLeft + currID
    end
    currID = currID - ((currID % partlen))
    if currID<=0 then
        currID = #BLeft + currID
    end
    local nextID = currID + 1

    render.setBlendMode(4)
    -- render.setBlendMode(13)
    render.setDepthMode(4)
    local color = rgbm.colors.white
    -- result       vec2( distance, steerangle )
    local ucTurn2 = ac.getTrackUpcomingTurn(0)
    -- ucTurn = vec2(ucTurn2.x, ucTurn2.y)
    -- ucTurn = vec2(ucTurn2.x*CUSTOM_MULT/2, ucTurn2.y*CUSTOM_MULT/2)
    -- ucTurn = vec2(ucTurn2.x/CUSTOM_MULT, math.abs(ucTurn2.y)*CUSTOM_MULT)
    -- ucTurn = vec2(ucTurn2.x*CUSTOM_MULT, math.abs(ucTurn2.y)*CUSTOM_MULT)
    -- ucTurn = vec2(ucTurn2.x/car.speedKmh/10*CUSTOM_MULT, math.abs(ucTurn2.y)/60*CUSTOM_MULT)
    local ucTurnDist = ucTurn2.x -- /car.speedKmh/10*CUSTOM_MULT
    local ucTurnAngle = math.abs(ucTurn2.y) --*1/CUSTOM_MULT

    while stepsdone<stepswanted do
        if currID<=0 then
            currID = 1
            nextID = currID + partlen*AIskipVar
        end
        if currID>#BLeft then
            currID = currID - #BLeft
            currID = currID - ((currID % partlen))
            nextID = currID + partlen*AIskipVar
        end
        if nextID>=#BLeft then
            nextID = nextID - #BLeft
        end

        if stepsdone>1 and currID>0 and currID<#BLeft and nextID>0 and nextID<#BLeft then
            if bAIideal and (currID % (AIskipVar*partlen) == 0) then
                -- if  (ucTurn.y > 1.25 and ucTurn.x/2 < car.speedKmh/5)
                -- if  (ucTurn.y + ucTurn.x < 1 )
                if (   (ucTurnAngle > 0.65 and ucTurnDist < car.speedKmh/5)
                    or (ucTurnAngle > 1.50 and ucTurn.x == 0))
                    -- and stepsdone-leadinCount > leadinCount+ucTurn2.x/2
                    -- or (ucTurn.x+1)/ucTurn.y*car.speedMs<1.0
                then
                    if bAImonocolor then
                        color = rgbm(rgbSingleColor.r*glowmult, rgbSingleColor.g*glowmult, rgbSingleColor.b*glowmult, glowmult*exposure*10)
                    else
                        -- color = rgbm(1*glowmult,0,0,glowmult*exposure*10)
                        -- lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                        -- lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent-dt, 0, 1)
                        -- color = rgbm(lineFadeRedCurrent*glowmult,
                        --              lineFadeGreenCurrent*glowmult,
                        --              0,glowmult*exposure*10)
                        color = rgbm((0.5+math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5))*glowmult,
                                         (math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5))*glowmult,
                                     0,glowmult*exposure*10)
                    end
                    render.quad(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color*10, texAIline)

                    if bDriveHint and
                       ucTurn2.x > 0 and
                       stepsdone-leadinCount >= ucTurn2.x and
                       stepsdone-leadinCount <  ucTurn2.x +(AIskipVar*partlen)
                    then
                        render.debugArrow(BIdealC[currID]+vUp*2, BIdealC[currID], 0.25, rgbm.colors.white*10)
                    end

                -- elseif (ucTurn.y > 1.0 and ucTurn.x/2 < car.speedKmh/5)
                elseif ((ucTurnAngle > 0.65 and ucTurnDist < car.speedKmh/5)
                     or (ucTurnAngle > 1.00 and ucTurn.x == 0))
                    -- and stepsdone-leadinCount > leadinCount+ucTurn2.x/2
                    --    or (ucTurn.x+1)/ucTurn.y*car.speedMs<1.5
                then
                    if bAIonlyWhenNotYellow then
                        if bAImonocolor then
                            color = rgbm(rgbSingleColor.r*glowmult, rgbSingleColor.g*glowmult, rgbSingleColor.b*glowmult, exposure*glowmult*10)
                        else
                            -- color = rgbm(1*glowmult,1*glowmult,0,exposure*glowmult*100)
                            -- lineFadeRedCurrent=math.clamp(lineFadeRedCurrent+dt, 0, 1)
                            -- lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                            -- color = rgbm(lineFadeRedCurrent*glowmult,
                            --              lineFadeGreenCurrent*glowmult,
                            --              0,glowmult*exposure*10)
                            color = rgbm((    math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5))*glowmult,
                                         (0.5+math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5))*glowmult,
                                         0,glowmult*exposure*10)
                       end
                       render.quad(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color*10, texAIline)
                       if bDriveHint and
                        ucTurn2.x > 0 and
                        stepsdone-leadinCount >= ucTurn2.x and
                        stepsdone-leadinCount <  ucTurn2.x +(AIskipVar*partlen)
                        then
                            render.debugArrow(BIdealC[currID]+vUp*2, BIdealC[currID], 0.25, rgbm.colors.white*10)
                        end

                    end
                elseif bAIonlyWhenNotGreen then
                    if bAImonocolor then
                        color = rgbm(rgbSingleColor.r*glowmult, rgbSingleColor.g*glowmult, rgbSingleColor.b*glowmult, exposure*glowmult*10)
                    else
                        color = rgbm(0.5-math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5)*glowmult,
                                     0.5+math.clamp(ucTurn.x/car.speedKmh/3.6*2, 0, 0.5)*glowmult,0,exposure*glowmult*10)
                        -- lineFadeRedCurrent=math.clamp(lineFadeRedCurrent-dt, 0, 1)
                        -- lineFadeGreenCurrent=math.clamp(lineFadeGreenCurrent+dt, 0, 1)
                        -- color = rgbm(lineFadeRedCurrent*glowmult,
                        --              lineFadeGreenCurrent*glowmult,
                        --              0,glowmult*exposure*10)
                    end
                    -- render.glSetColor(color)
                    render.quad(BIdealL[currID], BIdealR[currID], BIdealR[nextID], BIdealL[nextID], color*10, texAIline)
                end


                if bDriveHint and
                   --stepsdone-leadinCount+10 >= ucTurn2.x and
                   --stepsdone-leadinCount+10 <  ucTurn2.x +(AIskipVar*partlen) then
                   stepsdone-leadinCount >= 10 and
                   stepsdone-leadinCount <  10 +(AIskipVar*partlen)
                then
                    -- render.debugText(BIdealC[currID]+vUp*2,
                    --     -- tostring("kmh "..math.round(car.speedKmh,1)).."\n"..
                    --     -- tostring("mps "..math.round(car.speedMs,1)).."\n"..
                    --     tostring("distraw "..math.round(ucTurn.x,1)).."\n"..
                    --     tostring("anglraw "..math.round(ucTurn.y,1)).."\n",
                    --     -- tostring("dist "..math.round(ucTurn.x/(car.speedKmh+1)*100,1)).."\n"..
                    --     -- tostring("angl "..math.round(ucTurn.y*car.speedMs/1000,1)),
                    --     rgbm.colors.white, 3, render.FontAlign.Center)
                    -- render.setBlendMode(4)
                    -- render.setDepthMode(4)
                end
            end
            if bAIborders and currID>0 then
                --color = rgbm(rgbBorder.r, rgbBorder.g, rgbBorder.b, exposure*glowmultB*10)
                render.quad(BLeft [currID], BLeft[nextID],
                            BLeft2[nextID], BLeft2[currID],
                            rgbBorder*exposure*glowmultB*10, texBorder)
                render.quad(BRight [currID], BRight[nextID],
                            BRight2[nextID], BRight2[currID],
                            rgbBorder*exposure*glowmultB*10, texBorder)
            end
        end
        if stepsdone>=leadinCount then
        -- ucTurn2.x = math.max(ucTurn2.x - partlen/2, 0)
        -- ucTurn.x = ucTurn2.x/car.speedKmh/5*CUSTOM_MULT
        ucTurnDist = math.max(ucTurnDist - partlen/2, 0)
        -- ucTurnAngle = math.abs(ucTurn2.y)/60*CUSTOM_MULT
        end
        stepsdone = stepsdone + partlen
        currID = currID + partlen
        nextID = currID + partlen
    end
end









function script.windowSettings(dt)

    ui.beginOutline()

    -- ac.debug("trackid", ac.getTrackFullID("_"))
    if ac.getTrackFullID("_")=="ks_nordschleife_nordschleife" then
        if not tablecontains(Sects, "Sabine-Schmitz-Kurve") then
            ui.sameLine(200)
            if ui.button("UPDATE 'sections.ini' - add Sabine-Schmitz-Kurve") then
                --io.deleteFile(sectINI)
                if not io.copyFile(ac.getFolder(ac.FolderID.ACAppsLua)..'/JumpAILine/new_sections/ks_nordschleife_nordschleife/sections.ini', sectINI, false) then
                    ac.debug("copy failed","")
                end
                LoadSectionsIni()
            end
            ui.newLine(5)
        end
    end
    if ac.getTrackFullID("_")=="ks_nordschleife_endurance" then
        if not tablecontains(Sects, "Sabine-Schmitz-Kurve") then
            ui.sameLine(200)
            if ui.button("UPDATE 'sections.ini' - add Sabine-Schmitz-Kurve") then
                io.copyFile(ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/new_sections/ks_nordschleife_endurance/sections.ini', sectINI, false)
                LoadSectionsIni()
            end
            ui.newLine(5)
        end
    end
    if ac.getTrackFullID("_")=="ks_nordschleife_endurance_cup" then
        if not tablecontains(Sects, "Sabine-Schmitz-Kurve") then
            ui.sameLine(200)
            if ui.button("UPDATE 'sections.ini' - add Sabine-Schmitz-Kurve") then
                io.copyFile(ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/new_sections/ks_nordschleife_endurance_cup/sections.ini', sectINI, false)
                LoadSectionsIni()
            end
            ui.newLine(5)
        end
    end
    if ac.getTrackFullID("_")=="ks_nordschleife_touristenfahrten" then
        if not tablecontains(Sects, "Sabine-Schmitz-Kurve") then
            ui.sameLine(200)
            if ui.button("UPDATE 'sections.ini' - add Sabine-Schmitz-Kurve") then
                io.copyFile(ac.getFolder(ac.FolderID.Root)..'/apps/lua/JumpAILine/new_sections/ks_nordschleife_touristenfahrten/sections.ini', sectINI, false)
                LoadSectionsIni()
            end
            ui.newLine(5)
        end
    end

    if ui.button(textsteer) then
        ToggleSteeringWheel()
    end
    ui.sameLine(0,10)
    if ui.button(textdriver) then
        ToggleDriver()
    end
    ui.sameLine(0,5)
    if ui.checkbox("km's", bKMs) then
        bKMs = not bKMs
        if bKMs then
            writeACConfig(appini, 'CONTROLS', 'KMs', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'KMs', "0")
        end
    end

    ui.sameLine(0,5)
    if ui.checkbox("PoT %", bPoT) then
        bPoT = not bPoT
        if bPoT then
            writeACConfig(appini, 'CONTROLS', 'PoT', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'PoT', "0")
        end
    end

    ui.sameLine(0,5)
    if ui.checkbox("next/prev  ", bSections)
    then
        bSections = not bSections
        if bSections then
            writeACConfig(appini, 'CONTROLS', 'Sections', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'Sections', "0")
        end
    end

    ui.sameLine(0,5)
    if ui.checkbox("Btn's", bButtons)
    then
        bButtons = not bButtons
        if bButtons then
            writeACConfig(appini, 'CONTROLS', 'Buttons', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'Buttons', "0")
        end
    end

    ui.sameLine(0,5)
    if ui.checkbox("Reload Btn", bButtonReload)
    then
        bButtonReload = not bButtonReload
        if bButtonReload then
            writeACConfig(appini, 'CONTROLS', 'ButtonReload', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'ButtonReload', "0")
        end
    end
    ui.sameLine(0,5)
    if ui.checkbox("NamesOnTrack", bDrawCornersOnTrack)
    then
        bDrawCornersOnTrack = not bDrawCornersOnTrack
        if bDrawCornersOnTrack then
            writeACConfig(appini, 'USERSETTINGS', 'CORNERNAMESONTRACK', "1")
        else
            writeACConfig(appini, 'USERSETTINGS', 'CORNERNAMESONTRACK', "0")
        end
    end

    -- if #BGas==0 or #BBrake==0 or ac.getPatchVersionCode()<3044 then
    if #BGas==0 or #BBrake==0 or ac.getPatchVersionCode()<3044 then
        ui.newLine(0)
        ui.sameLine(320)
        ui.setCursorY(ui.getCursorY()-ac.getUI().uiScale*10)
        ui.bulletText("could not open ai line, CSP 0.2.3 needed!\n"..
                      "dynamic AI line not available")
    end

    ui.setNextItemWidth(50)
    if ui.checkbox("Background      ", bBackground) then
        bBackground = not bBackground
        if bBackground then
            writeACConfig(appini, 'CONTROLS', 'BACKGROUND', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'BACKGROUND', "0")
        end
    end

    ui.sameLine(0,0)
    ui.setNextItemWidth(250)
    fntSize, changed = ui.slider('##Font size:', fntSize, 6, 64, "Font size: %d" % fntSize, 1)
    if changed then
        fntSize = math.floor(fntSize)
        fntSizeSmall = math.floor(0.666*fntSize)
        writeACConfig(appini, 'USERSETTINGS', 'FONTSIZE', fntSize)
    end

    ui.sameLine(0,40)
    ui.colorButton('Current Section color', editcolor, ui.ColorPickerFlags.PickerHueBar)
    if editcolor ~= rgbCurrentSection then
        rgbCurrentSection = editcolor:clone()
        writeACConfig(appini, 'USERSETTINGS', 'SECTIONCOLOR', rgbCurrentSection)
    end

    ui.sameLine(0,40)
    ui.colorButton('Border color', editcolor2, ui.ColorPickerFlags.PickerHueBar)
    if editcolor2 ~= rgbBorder then
        rgbBorder = editcolor2:clone()
        writeACConfig(appini, 'USERSETTINGS', 'BORDERCOLOR', rgbBorder)
    end

    ui.sameLine(0,20)
    -- ui.setCursorX(150)
    -- ui.setCursorY(20)
    if physics.allowed() then
        ui.bulletText('extPhys on.')
    else
        ui.bulletText('extPhys OFF!\nNo Jumping!')
    end

    ui.setNextItemWidth(450)
    jumpdist, changed = ui.slider('##jumpdist', jumpdist, 0, math.max(400, math.floor(sim.trackLengthM/2)), "jumpdist: %d meter" % jumpdist, 1)
    if changed then
        jumpdist = math.floor(jumpdist)
        writeACConfig(appini, 'USERSETTINGS', 'JUMPDIST', jumpdist)
    end


    -- if #BLeft>0 and #BBrake>0 and ac.getPatchVersionCode()>=3044 then
    -- if #BLeft>0 and ac.getPatchVersionCode()>=3044 then
    if #BLeft2>0 then
        ui.sameLine(0,20)
        ui.setNextItemWidth(150)
        leadinCount, changed = ui.slider('##leadin/behind', leadinCount, 0, 50, "leadin/behind: %d" % leadinCount, 1)
        if changed then
            leadinCount = math.floor(leadinCount)
            writeACConfig(appini, 'USERSETTINGS', 'LEADINCOUNT', math.floor(leadinCount))
        end

        if ui.checkbox("AI borders", bAIborders) then
            bAIborders = not bAIborders
            writeACConfig(appini, 'CONTROLS', 'AIBORDERS', bAIborders)
        end


        ui.sameLine(130)
        ui.setCursorY(ui.getCursorY()+15)
        ui.setNextItemWidth(120)
        partlen, changed = ui.slider('##part len', partlen, 1, 8, 'part len: %dm' % partlen, 1)
        if changed then
            partlen = math.floor(partlen)
            -- no!1!11!
            -- borderDist = brdDist/sim.trackLengthM   --- those meters above in percent of track
            writeACConfig(appini, 'USERSETTINGS', 'AILINE_DISTANCE', partlen)
        end
        if ui.itemHovered() then
            if tooltimer>0.0 then
                tooltimer=tooltimer-dt
            end
            if tooltimer>0.0 then
                ui.tooltip(function () ui.text('recommended: > 1') end )
            end
        else
            tooltimer = 4.0
        end

        ui.sameLine(270,0)
        ui.setNextItemWidth(200)
        ai_renderlength, changed = ui.slider('##parts to draw: ', ai_renderlength, 2, math.max(10, #BLeft), "parts to draw:  %d" % ai_renderlength, 2)
        if changed then
            ai_renderlength = math.floor(ai_renderlength)
            writeACConfig(appini, 'USERSETTINGS', 'AI_RENDERLENGTH', ai_renderlength)
        end
        if ui.itemHovered() then
            ui.tooltip(function () ui.text('dont use more than 300!!!\n~0.7ms without borders!!!') end )
        end

        ui.sameLine(490)
        ui.setNextItemWidth(150)
        ui.setCursorY(ui.getCursorY()-15)
        glowmultB, changed = ui.slider('##border glow', glowmultB, 0.5, 10, "border glow: %.1f" % glowmultB, 1)
        if changed then
            glowmultB = math.round(glowmultB, 1)
            writeACConfig(appini, 'USERSETTINGS', 'GLOWMULTBORDER', glowmultB)
        end


        -- editF = ui.slider('##Finish', editF, 0.0, 1.0, 'Finish: %.8f', 1 )
        if ui.checkbox("AI ideal", bAIideal) then
            bAIideal = not bAIideal
            if bAIideal then
                writeACConfig(appini, 'CONTROLS', 'AIIDEAL', "1")
            else
                writeACConfig(appini, 'CONTROLS', 'AIIDEAL', "0")
            end
        end

        ui.sameLine(490)
        ui.setNextItemWidth(150)
        glowmult, changed = ui.slider('##ideal glow', glowmult, 0.5, 10, "ideal glow: %.1f" % glowmult, 1)
        if changed then
            glowmult = math.round(glowmult,1)
            writeACConfig(appini, 'USERSETTINGS', 'GLOWMULT', glowmult)
        end
    end

    ui.setNextItemWidth(50)
    local selected = math.floor(AIskipVar)
    local valid = {1,2,3,4,5,6,7,8,9,10}
    ui.combo("skip", selected, function ()
        -- for k,v in pairs(Sects) do
        for i,v in pairs(valid) do
            if ui.selectable(tostring(i), v == selected) then
                -- JumpSection(Sects[i][1])
                AIskipVar = i
                writeACConfig(appini, 'CONTROLS', 'SKIPAIPARTS', AIskipVar)
            end
        end
    end)


    ui.sameLine(120)
    if ui.checkbox("ideal single color", bAImonocolor) then
        bAImonocolor = not bAImonocolor
        if bAImonocolor then
            writeACConfig(appini, 'CONTROLS', 'AIMONOCOLOR', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'AIMONOCOLOR', "0")
        end
    end
    if bAImonocolor then
        ui.sameLine(0,0)
        ui.colorButton('Single Color for AI line:', editcolor3, ui.ColorPickerFlags.PickerHueBar)
        if editcolor3 ~= rgbSingleColor then
            rgbSingleColor = editcolor3:clone()
            writeACConfig(appini, 'USERSETTINGS', 'AISINGLECOLOR', rgbSingleColor)
        end
    end

    ui.sameLine(270)
    ui.setNextItemWidth(140)
    if not bAImonocolor then
        CUSTOM_MULT, changed = ui.slider('##AI red offset', CUSTOM_MULT, 0.5, 4.0 , "AI red offset: %.2f" % CUSTOM_MULT, 1)
        if changed then
            CUSTOM_MULT = math.round(CUSTOM_MULT, 2)
            writeACConfig(appini, 'AI_MULT_PER_CAR', sCar, CUSTOM_MULT)
            -- local CUSTOM_MULT = tonumber( readACConfig(appini, 'AI_MULT_PER_CAR', sCar, 1.0) )
            -- writeACConfig(appini, 'USERSETTINGS', 'CUSTOM_MULT', CUSTOM_MULT)
        end
    end

    if #BGas>0 and #BBrake>0 and ac.getPatchVersionCode()>=3044 then
        ui.sameLine(490)
        local x, y = ui.getCursorX()-70, ui.getCursorY()  -- -24
        selected = TexturesAILine[idealTexture]
        ui.setNextItemWidth(150)
        -- ui.combo("ideal graphic", selected, function ()
        --     for i,v in pairs(TexturesAILine) do
        --         if ui.selectable(tostring(i), v == selected) then
        --             idealTexture = i
        --             writeACConfig(appini, 'USERSETTINGS', 'IDEALTEXTURE', idealTexture)
        --         end
        --     end
        -- end)
        idealTexture, changed = ui.slider('##ideal graphic', idealTexture, 1, #TexturesAILine, "ideal graphic: %d" % idealTexture)
        if changed then
            idealTexture = math.floor(idealTexture)
            texAIline = TexturesAILine[idealTexture]
            writeACConfig(appini, 'USERSETTINGS', 'IDEALTEXTURE', idealTexture)
        end
        ui.drawRectFilled(                         vec2(x,y), vec2(x+48,y+48), rgbm.colors.black)
        ui.drawImage(TexturesAILine[idealTexture], vec2(x,y), vec2(x+48,y+48))
    end

    ui.newLine()
    ui.sameLine(0)
    if not bAImonocolor then
        ui.setNextItemWidth(150)
        iDoColorFade, changed = ui.slider("##color mode", iDoColorFade, 0, 2, "color mode %d" % iDoColorFade, 1)
        if changed then
        --if ui.checkbox("fade colors", bDoColorFade) then
            iDoColorFade = math.floor(iDoColorFade)
            writeACConfig(appini, 'CONTROLS', 'DoColorFade', iDoColorFade)
        end
        if ui.itemHovered() then
            ui.tooltip(function () ui.text('0 - dynamic fading colors\n1 - dynamic stable corners\n2 - static by spline angle ') end )
        end
    else
        ui.newLine()
    end

    if not bAImonocolor then
        ui.sameLine(0,20)
        if iDoColorFade<2 then
            if ui.checkbox("green", bAIonlyWhenNotGreen) then
                bAIonlyWhenNotGreen = not bAIonlyWhenNotGreen
                if bAIonlyWhenNotGreen then
                    writeACConfig(appini, 'CONTROLS', 'AIWHENNOTGREEN', "1")
                else
                    writeACConfig(appini, 'CONTROLS', 'AIWHENNOTGREEN', "0")
                end
            end
        end
        if iDoColorFade==1 then
            ui.sameLine(0,5)
            if ui.checkbox("yellow", bAIonlyWhenNotYellow) then
                bAIonlyWhenNotYellow = not bAIonlyWhenNotYellow
                if bAIonlyWhenNotYellow then
                    writeACConfig(appini, 'CONTROLS', 'AIWHENNOTYELLOW', "1")
                else
                    writeACConfig(appini, 'CONTROLS', 'AIWHENNOTYELLOW', "0")
                end
            end
        end
    end

    -- ui.sameLine(0,5)
    ui.sameLine(490)
    if ui.checkbox("Marker", bCornerArrow) then
        bCornerArrow = not bCornerArrow
        writeACConfig(appini, 'USERSETTINGS', 'CornerArrow', bCornerArrow)
    end

    -- ui.sameLine(0,5)
    -- if ui.checkbox("Pedal", bDriveHint) then
    --     bDriveHint = not bDriveHint
    --     writeACConfig(appini, 'USERSETTINGS', 'DriveHint', bDriveHint)
    -- end

    -- ui.sameLine(0,5)
    -- if ui.checkbox("debugegug", bDebugText) then
    --     bDebugText = not bDebugText
    --     writeACConfig(appini, 'USERSETTINGS', 'DebugText', bDebugText)
    -- end



    ui.text('AIborders')
    ui.sameLine(80)
    joystickbuttonAI:control(vec2(80, 0))
    if physics.allowed() then
        ui.sameLine(180)
        ui.text('stepback:')
        ui.sameLine(240)
        joystickbuttonstepback:control(vec2(80, 0))
        ui.sameLine(330)
        ui.text('stepforw:')
        ui.sameLine(390)
        joystickbuttonstepforw:control(vec2(80, 0))
        ui.sameLine(0,45)
        ui.text('reset:')
        ui.sameLine(0,0)
        joystickbuttonreset:control(vec2(80, 0))
    end

    ui.text('AI line')
    ui.sameLine(80)
    joystickbuttonideal:control(vec2(80, 0))
    if physics.allowed() then
        ui.sameLine(180)
        ui.text('sectPrev:')
        ui.sameLine(240)
        joystickbuttonsectPrev:control(vec2(80, 0))
        ui.sameLine(330)
        ui.text('sectNext:')
        ui.sameLine(390)
        joystickbuttonsectNext:control(vec2(80, 0))
        ui.sameLine(0,25)
        ui.text('Names:')
        ui.sameLine(0,8)
        joystickbuttonCornerNames:control(vec2(80, 0))
    end

    ui.text('MEM:')
    ui.sameLine(80)
    joystickbuttonMEM:control(vec2(80, 0))
    ui.sameLine(165)
    ui.text('jump-MEM:')
    ui.sameLine(240)
    joystickbuttonJUMPMEM:control(vec2(80, 0))
    ui.sameLine(330)
    ui.text('AIoffset-')
    ui.sameLine(390)
    joystickbuttonAIoffsetDN:control(vec2(80, 0))
    ui.sameLine(0,10)
    ui.text('AIoffset+')
    ui.sameLine(0,15)
    joystickbuttonAIoffsetUP:control(vec2(80, 0))
    ui.endOutline(rgbm.colors.black, 1)
end



function script.Draw3D(dt)

    if #BLeft>0 and car then
        if upd>0.5 then
            upd=upd-dt
        else
            upd=1.0
            exposure = (math.max(0.01, ac.getSim().whiteReferencePoint/20))
            -- if ac.getSim().whiteReferencePoint>1 then
            --     exposure2 = exposure*2 --/2 -- /20
            --     --     exposure2 = 0.05
            -- else
            --     --     exposure2 = 2
            --     exposure2 = 100 -- exposure*100
            -- end
            -- ac.debug("exposure", exposure)
        end

        ac.debug("#Ghost", #BGhostIdealC)
        ac.debug("#GhostL", #BGhostIdealL)
        ac.debug("#Ideal", #BIdealC)
        ac.debug("#IdealL", #BIdealL)
        if bDrawCornersOnTrack then
            DrawCornerNames(dt, car.splinePosition)
        end
        if ghostfileID>0 then
            DrawGhost(dt, car.splinePosition)
        end
        if (bAIideal or bAIborders or bDriveHint or bCornerArrow) then
            if iDoColorFade==0 then
                DrawAILine(dt, car.splinePosition)
            else
                -- DrawAILineOrig(dt, car.splinePosition)
                DrawAILineOrigOrig(0.05*partlen, car.splinePosition)
            end
        end
    end
end

--ac.debug("physics.allowed()", tostring(physics.allowed()))

function script.update(dt)
    --ac.debug("car.ffbMultiplier", car.ffbMultiplier)
    if ffbTimer>0.0 then
        ffbTimer=ffbTimer-dt
        if ffbTimer<=0.0 then
            ac.setFFBMultiplier(lastFFB)
            lastFFB = 0.0
        end
    end

    if tooltimer2>0.0 then
        tooltimer2=tooltimer2-dt
        if tooltimer2<=0.0 then
            tooltimer2=0.1
            CheckCurrentSection()
        end
    end


    if sim.sessionTimeLeft > sesstimeleft then
        sesstimeleft = sim.sessionTimeLeft+0.002
    end

    if physics.allowed() then
        if second>0.0 then
            pushCar(dt)
            second = second - dt
        end
    end

    if keydelay>0.0 then
        keydelay = keydelay - dt
        return
    end

    if physics.allowed() then
        if keydelay<=0.0 and not sim.isReplayActive and not sim.isPaused then
            if joystickbuttonreset:down() then
                Reset()
                second = secondadd
                keydelay = 0.188
            end
            if joystickbuttonstepback:down() then
                SetBack()
                second = secondadd
                keydelay = 0.188
            end
            if joystickbuttonstepforw:down() then
                SetForw()
                second = secondadd
                keydelay = 0.188
            end
            if joystickbuttonsectPrev:down() then
                if prevSect~=nil then
                    JumpSection(prevSect[1])
                    second = secondadd
                    keydelay = 0.188
                end
            end
            if joystickbuttonsectNext:down() then
                if nextSect~=nil then
                    JumpSection(nextSect[1])
                    second = secondadd
                    keydelay = 0.188
                end
            end
        end
    end


    if joystickbuttonMEM:down() then
        local pos=car.position
        local dir=car.look
        writeACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'POS', pos)
        writeACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'DIR', vec3(-dir.x, dir.y, -dir.z))
        ui.toast(ui.Icons.Clipboard, 'Saved position.')
        keydelay = 0.188
    end
    if joystickbuttonJUMPMEM:down() then
        local pos=car.position
        local dir=car.look
        local s = readACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'POS', '0,0,0')
        local t = readACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'DIR', '0,0,0')
        if s~='0,0,0' and t~='0,0,0' then
            local ss = s:split(',')
            local tt = t:split(',')
            pos = vec3(tonumber(ss[1]), tonumber(ss[2]), tonumber(ss[3]))
            dir = vec3(tonumber(tt[1]), tonumber(tt[2]), tonumber(tt[3]))
            physics.setCarPosition(0, pos, dir)
        else
            ui.toast(ui.Icons.Clipboard, 'No saved position!')
        end
        keydelay = 0.188
    end

    if joystickbuttonAIoffsetUP:down() then
        if CUSTOM_MULT<3.0 then
        CUSTOM_MULT = math.round(CUSTOM_MULT + 0.1, 1)
        keydelay = 0.1
        ui.toast(ui.Icons.AppWindow, 'AI offset: '..tostring(CUSTOM_MULT))
    end
end
if joystickbuttonAIoffsetDN:down() then
    if CUSTOM_MULT>0.5 then
        CUSTOM_MULT = math.round(CUSTOM_MULT - 0.1, 1)
        keydelay = 0.1
        ui.toast(ui.Icons.AppWindow, 'AI offset: '..tostring(CUSTOM_MULT))
        end
    end

    if joystickbuttonCornerNames:down() then
        bDrawCornersOnTrack = not bDrawCornersOnTrack
        if bDrawCornersOnTrack then
            writeACConfig(appini, 'USERSETTINGS', 'CORNERNAMESONTRACK', "1")
        else
            writeACConfig(appini, 'USERSETTINGS', 'CORNERNAMESONTRACK', "0")
        end
    end

    if joystickbuttonAI:down() then
        bAIborders = not bAIborders
        if bAIborders then
            writeACConfig(appini, 'CONTROLS', 'AIBORDERS', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'AIBORDERS', "0")
        end
        keydelay = 0.188
    end
    if joystickbuttonideal:down() then
        bAIideal = not bAIideal
        keydelay = 0.188
        if bAIideal then
            writeACConfig(appini, 'CONTROLS', 'AIIDEAL', "1")
        else
            writeACConfig(appini, 'CONTROLS', 'AIIDEAL', "0")
        end
    end
end


---------------------------------------------------------------------------------------------


function script.windowMain(dt)
    if bBackground then
        ui.drawRectFilled(vec2(0,0), vec2(ui.windowSize().x, ui.windowSize().y), rgbm(0,0,0,0.25))
    end

    --------------- section stuff
    ui.newLine()
    if #BLeft>0 then    -- if ac.hasTrackSpline() then
        -- km info Text
        ui.setCursor(vec2(20,30+fntSize))
        if bKMs or bPoT then
            -- km info Text + spline pos
            local s = ""
            if bKMs then
                local currMeters = car.splinePosition*sim.trackLengthM
                if currMeters>1000 then
                    s=math.round(currMeters/1000, 3)..'km'
                else
                    s=math.floor(currMeters        )..'m'
                end
            end
            if bPoT then
                -- s=s .. "  " .. string.format("%.6f%%", car.splinePosition*100)
                s=s .. "  " .. string.format("%.4f", car.splinePosition)
                --s=laptime(car.lapTimeMs)
            end

            ui.beginGroup()
            local uisize = ui.measureDWriteText(s, fntSizeSmall*0.8)
            --ui.dwriteDrawText(s, fntSizeSmall*0.8, vec2(40,40), rgbm.colors.white)
            DrawTextWithShadows(s, fntSizeSmall, ui.Alignment.Start, vec2(20,40+fntSize), vec2(uisize.x + fntSize, fntSizeSmall), false, rgbSections)
            --DrawTextACWithShadows(s, fntSizeSmall*2.8, vec2(20,40+fntSize), vec2(uisize.x + fntSize/10,fntSizeSmall), rgbSections)
            ui.endGroup()

            -- copy PoT number value
            if ui.itemHovered() then
                if tooltimer>0.0 then
                    tooltimer=tooltimer-dt
                end
                if tooltimer>0.0 then
                    ui.tooltip(function () ui.text("click to copy PoT") end )
                end
            else
                tooltimer = 1.0
            end
            if ui.itemClicked() then
                ac.setClipboardText(tostring(math.round(car.splinePosition,8)))
                ui.toast(ui.Icons.Clipboard, tostring(math.round(car.splinePosition,8)) .. ' copied!')
            end
        end

        if #Sects>0 then
            -- prev section Text
            if bSections and prevSect~=nil then
                ui.sameLine(40,0)
                DrawTextWithShadows(prevSect[0], fntSizeSmall, ui.Alignment.Start, vec2(10+fntSize*0.8,30), vec2(ui.windowSize().x/2,fntSize), false, rgbSections)
            end

            -- current section Text
            ui.sameLine(1,0)
            if currSect>=0 then
                if bSections then
                    DrawTextWithShadows(Sects[currSect][0], fntSize, ui.Alignment.Center, vec2(0,40), vec2(ui.windowSize().x,fntSize*2), false, rgbCurrentSection)
                else
                    DrawTextWithShadows(Sects[currSect][0], fntSize, ui.Alignment.Center, vec2(0,40), vec2(ui.windowSize().x,fntSize*2), false, rgbCurrentSection)
                end
            else
                DrawTextWithShadows(" "      , fntSize, ui.Alignment.Center, vec2(0,40), vec2(ui.windowSize().x,fntSize*2), false, rgbCurrentSection)
            end

            -- next section Text
            if bSections then
                if nextSect~=nil then
                    local uisize = ui.measureDWriteText(nextSect[0], fntSizeSmall)
                    DrawTextWithShadows(nextSect[0], fntSizeSmall, ui.Alignment.End, vec2(ui.availableSpaceX()-uisize.x,30), vec2(uisize.x+1,fntSize), false, rgbSections)
                end
                ui.newLine()
            end
            ui.newLine()
        else
            ui.newLine()
        end

        if physics.allowed() and not ac.isInReplayMode() and bButtons then

            DrawTextWithShadows('<', fntSize, ui.Alignment.Start, vec2(10,30), vec2(fntSize*1,fntSize*1), false, rgbSections)
            ui.sameLine(0)
            ui.setCursorX(0)
            -- small jump prev section btn
            if ui.invisibleButton('<', vec2(fntSize*2,fntSize*1.2)) then
            --if ui.button('<', vec2(fntSize*1.2,fntSize*1.2)) then
                if #Sects>0 then
                    if prevSect~=nil then
                        JumpSection(prevSect[1])
                        second = secondadd
                    end
                else
                    SetBack()
                    second = secondadd
                end
            end

            -- small jump next section btn
            DrawTextWithShadows('>', fntSize, ui.Alignment.End, vec2(ui.availableSpaceX()-fntSize*0.25,30), vec2(fntSize*1,fntSize*1), false, rgbSections)
            ui.sameLine(ui.windowSize().x-fntSize*3)
            if ui.invisibleButton('>', vec2(fntSize*2,fntSize*1.2)) then
            --if ui.button('>', vec2(fntSize*1.2,fntSize*1.2)) then
                if #Sects>0 then
                    if nextSect~=nil then
                        JumpSection(nextSect[1])
                        second = secondadd
                    end
                else
                    SetForw()
                    second = secondadd
                end
            end

            -- sections dropdown combobox
            if #Sects>0 then
                ui.setCursor(vec2(ui.availableSpaceX()-5,40+fntSize))
                ui.setNextItemWidth(20)
                -- Sects = { ["Sector1"]="T1", ["Sector2"]="T2" }
                local selected = Sects[1][0]
                ui.combo("", selected, function ()
                    for i,v in pairs(Sects) do
                        if ui.selectable(v[0], v[0] == selected) then
                            JumpSection(Sects[i][1])
                        end
                    end end)
            end
        end
    end

    if (sim.raceSessionType==ac.SessionType.Hotlap or sim.raceSessionType==ac.SessionType.Practice) then
        ui.newLine(3)
    else
        ui.newLine(0)
    end

    if physics.allowed() and bButtons and #BLeft>0 then   --- ac.hasTrackSpline() then
        if #Sects==0 then
            ui.newLine(0)
        end
        -- if #Sects==0 then
        if ui.button('Jump\nBack') then
            SetBack()
            second = secondadd
        end
        ui.sameLine(0,10)
        if ui.button('Jump\nForw') then
            SetForw()
            second = secondadd
        end
        ui.sameLine(0,10)
        if ui.button('Reset') then
            Reset()
            second = secondadd
        end
        ui.sameLine(0,10)
        if ui.button('Jump\nPits') then
            SetPits()
        end
    else
        -- ui.newLine()
    end
    if bButtons and #BLeft>0 then   --- ac.hasTrackSpline() then
        local wxx = ui.getCursorX()
        -- ideal line file selection
        if #availableSplines > 1 then
            ui.sameLine(0,10)
            wxx = ui.getCursorX()
            --ui.setCursorX(ui.windowWidth()-140)
            ui.setNextItemWidth(ui.availableSpaceX())

            local selected = io.getFileName(splineFilename, false)
            ui.combo('##fastidealsele',  selected, function ()
                for _, v in ipairs(availableSplines) do
                    if ui.selectable(io.getFileName(v), io.getFileName(v) == selected) then
                        splineFilename = v
                        writeACConfig(appini, 'USERSETTINGS', 'AILINE_FILE' , io.getFileName(v))
                        -- ac.debug("file", v)
                        if io.getFileName(splineFilename) == "fast_lane.ai" then
                            -- ReadAILINE(splineFilename)
                            CreateBorders()
                        else
                            ReadAILINE(splineFilename)
                        end
                    end
                end
            end)
        end

        if #BGhostFiles>0 then
            ui.newLine(0)
            ui.setCursorX(wxx)
            if physics.allowed() then
            ui.setCursorY(ui.getCursorY()-30)
            else
            ui.setCursorY(ui.getCursorY()-15)
            end
            ui.setNextItemWidth(ui.availableSpaceX())
            ac.debug("ghostfileID", ghostfileID)
            local selected2 = tostring(BGhostFiles[ghostfileID]):replace('GHOST_CAR_',''):replace('.ghost','')
            ui.combo('##ghost',  selected2, function ()
                for i=0, #BGhostFiles do
                    if ui.selectable(tostring(BGhostFiles[i]):replace('GHOST_CAR_',''):replace('.ghost',''), tostring(BGhostFiles[i]):replace('GHOST_CAR_',''):replace('.ghost','') == selected2) then
                        ghostfileID = i
                        writeACConfig(appini, 'USERSETTINGS', 'GHOSTID' , tostring(ghostfileID))
                        -- writeACConfig(appini, 'USERSETTINGS', 'GHOSTID' , io.getFileName(ghostfile[ghostfileID]))
                        if ghostfileID>0 then
                            if BGhostFiles[ghostfileID]:lower():endsWith('grooveline.csv') then
                                ReadCSVFile(BGhostFiles[ghostfileID], false)
                            elseif BGhostFiles[ghostfileID]:lower():endsWith('.csv') then
                                ReadCSVFile(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[ghostfileID], false)
                            else
                                ReadGhostFile(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[ghostfileID], false)
                            end
                        end
                    end
                    -- if i==ghostfileID and ui.itemHovered() then
                    if ui.itemHovered() then
                        if i==0 then
                            ui.tooltip(function ()
                                ui.text("Select Ghost/CSV as extra overlay")
                            end)
                        elseif BGhostDetail[i][2]~="" then
                            ui.tooltip(function ()
                                if BGhostDetail[i][1]~="" then
                                    ui.text("Ghost laptime: " ..BGhostDetail[i][1]..
                                        '\nfrom '..BGhostDetail[i][2])
                                else
                                    ui.text("from "..BGhostDetail[i][2])
                                end
                            end)
                        end
                    end
                end
            end)
            if ui.itemHovered() then
                if BGhostDetail[ghostfileID][2]~="" then
                    ui.tooltip(function ()
                        if BGhostDetail[ghostfileID][1]~="" then
                            ui.text("Ghost laptime: " ..BGhostDetail[ghostfileID][1]..
                                "\nfrom "..BGhostDetail[ghostfileID][2])
                        else
                            ui.text("from "..BGhostDetail[ghostfileID][2])
                        end
                    end)
                else
                    ui.tooltip(function ()
                    ui.text("Select Ghost/CSV as extra overlay")
                    end)
                end
            end
        end
    end

    ui.sameLine(0)
    if bButtons then
        ui.newLine()
        local pos=car.position
        local dir=car.look
        if ui.button('MEM') then
            writeACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'POS', pos)
            writeACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'DIR', vec3(-dir.x, dir.y, -dir.z))
            ui.toast(ui.Icons.Clipboard, 'Saved position.')
        end
        ui.sameLine()
        if ui.button('jump MEM') then
            local s = readACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'POS', '0,0,0')
            local t = readACConfig(appini, 'MEM_'..ac.getTrackFullID("_"), 'DIR', '0,0,0')
            if s~='0,0,0' and t~='0,0,0' then
                local ss = s:split(',')
                local tt = t:split(',')
                pos = vec3(tonumber(ss[1]), tonumber(ss[2]), tonumber(ss[3]))
                dir = vec3(tonumber(tt[1]), tonumber(tt[2]), tonumber(tt[3]))
                physics.setCarPosition(0, pos, dir)
            else
                ui.toast(ui.Icons.Clipboard, 'No saved position!')
            end
        end
        ui.sameLine(0)
        if bButtonReload then
            ui.setCursorX(ui.windowWidth()-200)
            ui.text("sections.ini")
            ui.sameLine(0)
            ui.setCursorX(ui.windowWidth()-120)
            if ui.button("edit") then
                if not io.fileExists(sectINI) then
                    writeACConfig(sectINI, "SECTION_0", "IN", "0.0")
                    writeACConfig(sectINI, "SECTION_0", "OUT", "0.1")
                    writeACConfig(sectINI, "SECTION_0", "TEXT", "First corner")
                    writeACConfig(sectINI, "SECTION_1", "IN", "0.1")
                    writeACConfig(sectINI, "SECTION_1", "OUT", "0.2")
                    writeACConfig(sectINI, "SECTION_1", "TEXT", "Second corner")
                end
                os.openTextFile(sectINI, 1)
                -- os.showInExplorer(sectINI)
            end
            ui.sameLine(1)
            ui.setCursorX(ui.windowWidth()-70)
            if ui.button("reload") then
                LoadSectionsIni()
            end
        end


        if sim.freeCameraAllowed then
            if ui.button('freecam to 0') then
                pos = vec3(0, 0, 0)
                dir = vec3(0, 0, 1)
                ac.setCurrentCamera(ac.CameraMode.Free)
                ac.setCameraPosition(pos)
                ac.setCameraDirection(dir)
            end
            ui.sameLine()
            if ui.button('top view') then
                dir = ac.getCameraForward()
                dir.z=-1
                ac.setCurrentCamera(ac.CameraMode.Free)
                ac.setCameraDirection(dir)
            end
        else
            ui.text("freecam not allowed")
        end
        ui.sameLine()
        if ui.button('get dir') then
            local dr = ac.getCameraForward()
            local ss = 'FORWARD='..tostring(vec3(dr.x, dr.y, dr.z))
            ac.setClipboadText(ss)
            ui.toast(ui.Icons.Clipboard, 'Copied direction: ' .. ss)
            -- local dr = ac.getCameraForward()
            -- local ss = 'FORWARD='..tostring(dr)
            -- ac.setCameraDirection(vec3(dir.x, dir.y, 0))
        end
        -- ui.sameLine()
        if ui.button('custom jump') then
            -- pos = vec3(-1259.98, -52.0506, -4630.01)
            -- -- pos = vec3(-130.269, -5.08055, 468.017)
            -- -- pos = vec3(4297.83, 5.80, -3787.12)
            -- -- dir = vec3(0, 0, 1)

            pos = vec3(-306.204, -9.29331, -231.013)
            ac.setCurrentCamera(ac.CameraMode.Free)
            ac.setCameraPosition(pos)

            -- local m=ac.findNodes('trackRoot:yes'):findMeshes("Fuselage")
            -- ac.debug("#", #m)
            -- ac.setCameraPosition(m:getChild(1):getPosition())
        end
        -- if ui.itemActive() then
        --     ac.flashLights()
        -- end
    end

    if sim.isReplayActive then
        if ui.button("-10 frames") then
            ac.setReplayPosition(sim.replayCurrentFrame-10,0)
        end
        ui.sameLine(0,10)
        if ui.button("-1 frame") then
            ac.setReplayPosition(sim.replayCurrentFrame-1,0)
        end
        ui.sameLine(0,10)
        if ui.button("+1 frame") then
            ac.setReplayPosition(sim.replayCurrentFrame+1,0)
        end
        ui.sameLine(0,10)
        if ui.button("+10 frames") then
            ac.setReplayPosition(sim.replayCurrentFrame+10,0)
        end
        ui.sameLine(0,10)
        ui.text(string.format("%d", sim.replayCurrentFrame))
        ui.sameLine(0,10)
        ui.text(" / ")
        ui.sameLine(0,10)
        ui.text(string.format("%d", sim.replayFrames))
    end

end

sectINI = ac.getFolder(ac.FolderID.Root) .. "\\content\\tracks\\" .. ac.getTrackFullID("\\") .. "\\" .. "data\\sections.ini"
LoadSectionsIni()

table.insert(BGhostFiles, 0, "OFF")
table.insert(BGhostDetail, 0, {[1]="", [2]=""})

-- ghostfile =
if sLayout=='' then
    -- local tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "GHOST_CAR_*" .. sCar ..                   ".ghost")
    local tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "GHOST_CAR_*" ..                            ".ghost")
    for i = 1, #tmp do
        table.insert(BGhostFiles, i, tmp[i])
    end
    tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "*"..".csv")
    for i = 1, #tmp do
        table.insert(BGhostFiles, i, tmp[i])
    end
    -- ghostfile = ghostfile .. sTrack .. "/GHOST_CAR_leBluem_" .. sCar ..                   ".ghost"
else
    -- local tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "GHOST_CAR_*" .. sCar .. "_" .. sLayout .. ".ghost")
    local tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "GHOST_CAR_*" ..                 sLayout .. ".ghost")
    for i = 1, #tmp do
        table.insert(BGhostFiles, i, tmp[i])
    end
    tmp = io.scanDir(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/", "*" ..                 sLayout .. "*.csv")
    for i = 1, #tmp do
        table.insert(BGhostFiles, i, tmp[i])
    end
    -- ghostfile = ghostfile .. sTrack .. "/GHOST_CAR_leBluem_" .. sCar .. "_" .. sLayout .. ".ghost"
end

-- ac.debug("ghostfiles", #BGhostFiles)
if #BGhostFiles>0 then
    -- pre read details from ghost files
    for i=1, #BGhostFiles do
        if tostring(BGhostFiles[i]):lower():endsWith(".csv") then
            local gt, gd = ReadCSVFile(  ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[i], true)
            table.insert(BGhostDetail, i, {[1]=gt, [2]=gd})
        else
            local gt, gd = ReadGhostFile(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[i], true)
            table.insert(BGhostDetail, i, {[1]=gt, [2]=gd})
            --ac.debug('k'..i, tostring(#BGhostDetail) .." " ..tostring(gt) .." " .. tostring(gd))
        end
    end
end

-- /data/groveline.csv there? from Esotic's "AI-Line-Helper"
-- https://www.overtake.gg/downloads/ai-line-helper.16016/
local groovefile = ac.getFolder(ac.FolderID.ContentTracks).."/"..ac.getTrackFullID("/") .. "/data/groveline.csv"
ac.debug("groovefile", groovefile)
if io.fileExists(groovefile) then
    ac.debug("groovefile found", groovefile)
    table.insert(BGhostFiles, groovefile)
    local gt, gd = ReadCSVFile( groovefile, true)
    table.insert(BGhostDetail, {[1]=gt, [2]=gd})
end


ghostfileID = math.min(ghostfileID, #BGhostFiles)
if ghostfileID>0 then
    if BGhostFiles[ghostfileID]:lower():endsWith('groveline.csv') then
        ReadCSVFile(  BGhostFiles[ghostfileID], false)
    elseif BGhostFiles[ghostfileID]:lower():endsWith('.csv') then
        ReadCSVFile(  ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[ghostfileID], false)
    else
        ReadGhostFile(ac.getFolder(ac.FolderID.Documents) .. "/Assetto Corsa/GhostCar/" .. sTrack .. "/" .. BGhostFiles[ghostfileID], false)
    end
end
-- ac.debug('ghost-time', laptime(ghosttime))
-- ac.debug('LEN       ghost', #BGhostIdealC)
-- ac.debug('LEN ghostdetail', #BGhostDetail)
-- ac.debug('ideal', #BGhostIdealL)
