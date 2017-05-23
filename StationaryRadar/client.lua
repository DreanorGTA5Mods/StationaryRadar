RegisterNetEvent('setRadar')

local speedcams = {};
local maxSpeedKmh = 1;
local maxSpeedMph = 10;
local hasBeenFucked = 0;

AddEventHandler('setRadar', function()
    table.insert(speedcams, GetEntityCoords(GetPlayerPed(-1)))
    --TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: "..a) 
end)

function SpeedBreak(value, numberplate)
    if value >= maxSpeedKmh then
        if hasBeenFucked == 0 then
            hasBeenFucked = 1
            local info = string.format("%s | %s mph / %s km/h", numberplate, math.ceil(value*2.236936), math.ceil(value*3.6))
            TriggerEvent("chatMessage", "[System]", { 255,0,0}, string.format("%s | %s mph / %s km/h", numberplate, math.ceil(value*2.236936), math.ceil(value*3.6)))
        end
    end
end

function HandleSpeedcam(camId)
    local speedcam = speedcams[camId]
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
			SpeedBreak(GetEntitySpeed(vehicle), numberplate)
        end
    else
        hasBeenFucked = 0
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)		
        if speedcams[1] ~=nil then
            for key,value in pairs(speedcams) do
                HandleSpeedcam(key)
                --TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: "..speedcams[1]) 
            end
        end
    end  
end)