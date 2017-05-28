require "resources/stationaryradar/lib/MySQL"
MySQL:open(databaseServer, database, databaseUser, databasePassword)

RegisterServerEvent('saveRadarPosition');
RegisterServerEvent('getRadars');
RegisterServerEvent('removeRadar');

local speedcams = {};
local refreshCache = true;

-----------------------------------------------------------------------
---------------------Events--------------------------------------------
-----------------------------------------------------------------------

-- Chatcommands which can be set by the police
AddEventHandler('chatMessage', function(player, playerName, message)
    local playersteamid = GetPlayerIdentifiers(player)[1];
    if (playerHasPermissions(playersteamid)) then
        if(message == "/set speedradar") then
            TriggerClientEvent('setRadar', player);
        end
        if(message == "/remove speedradar") then
            TriggerClientEvent('getRadarsToRemove', player);
        end
        if(message == "/show radars") then
            TriggerClientEvent('showRadars', player);
        end
        if(message == "/hide radars") then
            TriggerClientEvent('hideRadars', player);
        end
    end
end)

-- Deletes radar from database
AddEventHandler('removeRadar', function(x, y, z)
    local sql = string.format("delete from stationaryradar where x =%s and y =%s and z =%s)", round(x, 2), round(y, 2), round(z, 2));
    MySQL:executeQuery(sql);
end)

-- Loads Radars from the database and returns to the player
AddEventHandler('getRadars', function()
    if (refreshCache) then
        GetPlayerIdentifiers(source)
        local query = MySQL:executeQuery("SELECT * FROM stationaryradar");
        local result = MySQL:getResults(query, {'x', 'y', 'z', 'maxspeed'});
        if (result[1]) then
            refreshCache = false;
            for _, value in ipairs(result) do
                local position = { x = value.x, y = value.y, z = value.z };
                speedcams[position] = 0;
            end
        end
    end

    addPlayerToDatabase(source);
    TriggerClientEvent('loadRadars', source, speedcams);
    TriggerClientEvent('loadConfig', source, maxSpeedMph, speedcamRange, blipFlashTimeInMs);
end)

-- Saves new locations to the database
AddEventHandler('saveRadarPosition', function(x, y, z, maxspeed)
    local sql = string.format("INSERT INTO stationaryradar (`x`, `y`, `z`, `maxspeed`) VALUES ('%s', '%s', '%s', '%s')", tostring(round(x, 2)), tostring(round(y, 2)), tostring(round(z, 2)), maxspeed);
    MySQL:executeQuery(sql);

    --Refresh radars
    local position = { x = x, y = y, z = z };
    speedcams[position] = 0;
    TriggerClientEvent('loadRadars', source, speedcams);
    --Refresh blips
    TriggerClientEvent('hideRadars', source);
    TriggerClientEvent('showRadars', source);
end)

-----------------------------------------------------------------------
---------------------Functions-----------------------------------------
-----------------------------------------------------------------------

-- Rounds to last places
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- Checks if the player is a cop
function playerHasPermissions(steamId)
    local query = MySQL:executeQuery(string.format("SELECT * FROM stationaryradar_permissions WHERE steamid = '%s' and permission_level = 1", steamId));
    local result = MySQL:getResults(query, {'steamid'});
    return result[1];
end

-- Adds Player to the Permission table if not already existent
function addPlayerToDatabase(source)
    local playersteamid = GetPlayerIdentifiers(source)[1];
    local query = MySQL:executeQuery(string.format("SELECT * FROM stationaryradar_permissions where steamid = '%s'", playersteamid));
    local result = MySQL:getResults(query, {'steamid'});

    if (not result[1]) then
        MySQL:executeQuery(string.format("insert into stationaryradar_permissions (steamid, name, permission_level) values ('%s', '%s', 0)", playersteamid, GetPlayerName(source)));
    end
end
