RegisterNetEvent('setRadar')

local speedcams = {};
local maxSpeedKmh = 1;
local maxSpeedMph = 10;

AddEventHandler('setRadar', function()
    --table.insert(speedcams, { key = GetEntityCoords(GetPlayerPed(-1)), value = {0, 1}})
    speedcams[GetEntityCoords(GetPlayerPed(-1))] = 0
    --TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: ") 
end)

function SpeedBreak(speedcam, hasBeenFucked, speed, numberplate)
    if speed >= maxSpeedKmh then
        if hasBeenFucked == 0 then
            speedcams[speedcam] = 1
            local streethash = GetStreetNameAtCoord(speedcam['x'], speedcam['y'], speedcam['z'])
            local streetname = GetStreetNameFromHashKey(streethash)
            local info = string.format("%s | %s mph / %s km/h", numberplate, math.ceil(speed*2.236936), math.ceil(speed*3.6))
            TriggerEvent("chatMessage", "[System]", { 255,0,0}, string.format("%s | %s | %s mph / %s km/h", streetname, numberplate, math.ceil(speed*2.236936), math.ceil(speed*3.6)))
        end
    end
end

function HandleSpeedcam(speedcam, hasBeenFucked)
    local playerPos = GetEntityCoords(GetPlayerPed(-1))
    -- Sets radius in which speeding gets triggered
    local x1 = playerPos['x'] - speedcam['x']
    local x2 = speedcam['x'] - playerPos['x'] 
    local y1 = playerPos['y'] - speedcam['y']
    local y2 = speedcam['y'] - playerPos['y'] 
    local range = 20;

    if y1 <= range 
        and y2 <= range 
        and x1 <= range 
        and x2 <= range 
    then 
        local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
        if vehicle ~=nil then
            local numberplate = GetVehicleNumberPlateText(vehicle)
			SpeedBreak(speedcam, hasBeenFucked, GetEntitySpeed(vehicle), numberplate)
        end
    else
        speedcams[speedcam] = 0 --might remove that for logging of who got fucked where
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)		
        for key, value in pairs(speedcams) do
                --TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: "..key..value) 
            HandleSpeedcam(key, value)
        end
    end  
end)
