RegisterNetEvent('setRadar')
RegisterNetEvent('loadRadars')
RegisterNetEvent('showRadars')
RegisterNetEvent('hideRadars')

local speedcams = {};
local maxSpeedMph = 1;
local speedcamRange = 20;
local blips = {};

-----------------------------------------------------------------------
---------------------Events--------------------------------------------
-----------------------------------------------------------------------

-- Loads Radars into the client
AddEventHandler('loadRadars', function(loadedSpeedcams)
    speedcams = loadedSpeedcams;

end)

AddEventHandler('showRadars', function()
    for position, value in pairs(speedcams) do
        local blip = AddBlipForCoord(position['x'],position['y'],position['z'])
        blips[position] = blip;
    end
end)

AddEventHandler('hideRadars', function()
    for position, blip in pairs(blips) do
        RemoveBlip(blip);
    end
    blips = {};
end)

-- Manually set Radar
AddEventHandler('setRadar', function(array)
    local currentPos = GetEntityCoords(GetPlayerPed(-1));
    x, y, z = table.unpack(currentPos)
    TriggerServerEvent("saveRadarPosition", x, y, z, maxSpeedMph);
end)

-- Reguest to get all Radars
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("getRadars");
end)

-----------------------------------------------------------------------
---------------------Functions-----------------------------------------
-----------------------------------------------------------------------

-- Determines if player broke speed and message should be triggered
function SpeedBreak(speedcam, hasBeenFucked, speed, name, numberplate)
    local mphspeed = math.ceil(speed*2.236936);
    if mphspeed >= maxSpeedMph then
        if hasBeenFucked == 0 then
            speedcams[speedcam] = 1 -- player got busted by cam
            local streethash = GetStreetNameAtCoord(speedcam['x'], speedcam['y'], speedcam['z']);
            local streetname = GetStreetNameFromHashKey(streethash);
            local text = string.format("%s | %s | %s mph / %s km/h @ %s", name, numberplate, mphspeed, math.ceil(speed*3.6), streetname);
            TriggerEvent("chatMessage", "[Speedcam]", { 255,0,0}, text);
        end
    end
end

-- Determines if player is close enough to trigger cam
function HandleSpeedcam(speedcam, hasBeenFucked)
    local playerPos = GetEntityCoords(GetPlayerPed(-1));

    -- Sets radius in which speeding gets triggered
    local x1 = playerPos['x'] - speedcam['x'];
    local x2 = speedcam['x'] - playerPos['x'];
    local y1 = playerPos['y'] - speedcam['y'];
    local y2 = speedcam['y'] - playerPos['y'];

    if y1 <= speedcamRange
        and y2 <= speedcamRange 
        and x1 <= speedcamRange 
        and x2 <= speedcamRange
    then
        local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
        if (vehicle ~=nil) then
            local numberplate = GetVehicleNumberPlateText(vehicle);
            local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle));
            SpeedBreak(speedcam, hasBeenFucked, GetEntitySpeed(vehicle), name, numberplate);
        end
    else
        speedcams[speedcam] = 0;
    end
end

-----------------------------------------------------------------------
---------------------Threads-------------------------------------------
-----------------------------------------------------------------------

-- Thread to loop speedcams
Citizen.CreateThread(function()
    while true do
        Wait(0);
        for key, value in pairs(speedcams) do
            HandleSpeedcam(key, value);
        end
    end
end)