RegisterNetEvent('setRadar');
RegisterNetEvent('getRadarsToRemove');
RegisterNetEvent('loadRadars');
RegisterNetEvent('showRadars');
RegisterNetEvent('hideRadars');
RegisterNetEvent('loadConfig');

local speedcams = {};
local blips = {};
-----------------------------------------------------------------------
---------------------Events--------------------------------------------
-----------------------------------------------------------------------

-- Loads Radars into the client
AddEventHandler('loadRadars', function(loadedSpeedcams)
    speedcams = loadedSpeedcams;
end)

-- Shows blips on map
AddEventHandler('showRadars', function()
    for position, value in pairs(speedcams) do
        local blip = AddBlipForCoord(position['x'],position['y'],position['z'])
        blips[position] = blip;
    end
end)

-- Hides blips from map
AddEventHandler('hideRadars', function()
    for position, blip in pairs(blips) do
        RemoveBlip(blip);
    end
    blips = {};
end)

-- Hides blips from map
AddEventHandler('loadConfig', function(speed, speedRange, flashTime)
    maxSpeedMph = speed;
    speedcamRange = speedRange;
    blipFlashTimeInMs = flashTime;
end)

-- Manually set Radar
AddEventHandler('setRadar', function()
    local currentPos = GetEntityCoords(GetPlayerPed(-1));
    x, y, z = table.unpack(currentPos);
    TriggerServerEvent("saveRadarPosition", x, y, z, maxSpeedMph);
end)

-- Removes radar at current pos
AddEventHandler('getRadarsToRemove', function()
    local playerPos = GetEntityCoords(GetPlayerPed(-1));

    for cam, value in pairs(speedcams) do
        if (isPlayerInCamRange(cam, playerPos)) then
            x, y, z = table.unpack(cam);
            TriggerServerEvent("removeRadar", x, y, z)
        end
    end
end)

-- Reguest to get all Radars
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("getRadars");
end)

-----------------------------------------------------------------------
---------------------Functions-----------------------------------------
-----------------------------------------------------------------------

-- Determines if player is in cam range
function isPlayerInCamRange(speedcam, playerPos)
    local x1 = playerPos['x'] - speedcam['x'];
    local x2 = speedcam['x'] - playerPos['x'];
    local y1 = playerPos['y'] - speedcam['y'];
    local y2 = speedcam['y'] - playerPos['y'];

    return y1 <= speedcamRange
    and y2 <= speedcamRange
    and x1 <= speedcamRange
    and x2 <= speedcamRange;
end

-- Determines if player broke speed and message should be triggered
function SpeedBreak(speedcam, hasBeenFucked, speed, name, numberplate)
    local mphspeed = math.ceil(speed*2.236936);
    if mphspeed >= maxSpeedMph then
        if hasBeenFucked == 0 then
            speedcams[speedcam] = 1 -- player got busted by cam
            SetBlipFlashTimer(blips[speedcam], blipFlashTimeInMs)
            local streethash = GetStreetNameAtCoord(speedcam['x'], speedcam['y'], speedcam['z']);
            local streetname = GetStreetNameFromHashKey(streethash);
            local text = string.format("%s | %s | %s mph / %s km/h @ %s", name, numberplate, mphspeed, math.ceil(speed*3.6), streetname);
            --TriggerServerEvent("sendMessageToAllCops", text);
        end
    end
end

-- Determines if player is close enough to trigger cam
function HandleSpeedcam(speedcam, hasBeenFucked)
    local playerPos = GetEntityCoords(GetPlayerPed(-1));

    if (isPlayerInCamRange(speedcam, playerPos)) then
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
