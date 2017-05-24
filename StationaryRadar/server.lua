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

-- Loads Radars from Datasource and returns to the player
RegisterServerEvent('getRadars')
AddEventHandler('getRadars', function()
    -- todo load shit from db/file whatever also cache them?
    local speedcams = { x = 406, y = -968, z = 29 };
    TriggerClientEvent('loadRadars', source, speedcams);
end)