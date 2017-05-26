require "resources/stationaryradar/lib/MySQL"
MySQL:open("localhost", "gta", "root", "1234")

local speedcams = {};
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
    if(message == "/show radars") then
        TriggerClientEvent('showRadars', source);
    end
    if(message == "/hide radars") then
        TriggerClientEvent('hideRadars', source);
    end
end)

-- Loads Radars from the database and returns to the player
RegisterServerEvent('getRadars')
AddEventHandler('getRadars', function()
    if (refreshCache) then
        local query = MySQL:executeQuery("SELECT * FROM gta.stationaryradar")
        local result = MySQL:getResults(query, {'x', 'y', 'z', 'maxspeed'})
        if (result[1]) then
            refreshCache = false;
            for _, value in ipairs(result) do
                local position = { x = value.x, y = value.y, z = value.z };
                speedcams[position] = 0;

            end
        end
    end

    TriggerClientEvent('loadRadars', source, speedcams);
end)

-- Saves new locations to the database
RegisterServerEvent('saveRadarPosition')
AddEventHandler('saveRadarPosition', function(x, y, z, maxspeed)
    local sql = string.format("INSERT INTO `gta`.`stationaryradar` (`x`, `y`, `z`, `maxspeed`) VALUES ('%s', '%s', '%s', '%s')", tostring(round(x, 2)), tostring(round(y, 2)), tostring(round(z, 2)), maxspeed);
    MySQL:executeQuery(sql);

    --Refresh radars
    local position = { x = x, y = y, z = z };
    speedcams[position] = 0;
    TriggerClientEvent('loadRadars', source, speedcams);
end)

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end