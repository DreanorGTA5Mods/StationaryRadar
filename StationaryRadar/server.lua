require "resources/stationaryradar/lib/MySQL"
MySQL:open("localhost", "stationaryradar", "root", "1234")

local speedcamsCache = {};
local refreshCache = true;
-----------------------------------------------------------------------
---------------------Events--------------------------------------------
-----------------------------------------------------------------------

-- Chatcommands which can be set by the police
AddEventHandler('chatMessage', function(source, n, message)
    -- todo only for cops
    if(message == "/set speedradar") then
        TriggerClientEvent('setRadar', source);
    end
end)

-- Loads Radars from the database and returns to the player
RegisterServerEvent('getRadars')
AddEventHandler('getRadars', function()
    if refreshCache then
        refreshCache = false;
        local query = MySQL:executeQuery("SELECT * FROM stationaryradar.stationaryradar")
        local result = MySQL:getResults(query, {'x', 'y', 'z', 'maxspeed'})

        local speedcams = {};
        for _, value in ipairs(result) do
            local position = { x = value.x, y = value.y, z = value.z };
            speedcams[position] = 0;
        end

        speedcamsCache = speedcams;
    end

    TriggerClientEvent('loadRadars', source, speedcamsCache);
end)

-- Saves new locations to the database
RegisterServerEvent('saveRadarPosition')
AddEventHandler('saveRadarPosition', function(x, y, z, maxspeed)
    refreshCache = true;
    local sql = string.format("INSERT INTO `stationaryradar`.`stationaryradar` (`x`, `y`, `z`, `maxspeed`) VALUES ('%s', '%s', '%s', '%s')", math.floor(x+0.5), math.floor(y+0.5), math.floor(z+0.5), maxspeed);
    MySQL:executeQuery(sql);
    -- todo Trigger event to reload cache on all players
end)