RegisterNetEvent('setRadar')
local speedcam; -- todo: list for multiple locations
local maxSpeedKmh = 50;
local maxSpeedMph = 0;

AddEventHandler('setRadar', function()
    speedcam = GetEntityCoords(GetPlayerPed(-1))
    TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: "..pos['x']) 
end)

function SpeedBreak(value, maxSpeed, numberplate, text)
    if value >= maxSpeed then
        TriggerEvent("chatMessage", "[System]", { 255,0,0}, string.format("Plate: %s %s: %s", numberplate, text, math.ceil(value)))
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)		
        if speedcam ~=nil then
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
                    if maxSpeedKmh > 0 then
                        SpeedBreak(GetEntitySpeed(vehicle)*3.6, maxSpeedKmh, numberplate, "Km/h")
                    end
					
                    if maxSpeedMph > 0 then
                        SpeedBreak(GetEntitySpeed(vehicle)*2.236936, maxSpeedMph, numberplate, "Mph")
                    end
                end
            end
            Wait(1000) -- wait to not spam the server
        end
    end  
end)