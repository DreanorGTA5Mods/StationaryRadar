AddEventHandler('chatMessage', function(source, n, message)
  -- todo only for cops
  if(message == "/set speedradar") then
	setupCamera(source)
  end
end)

function setupCamera (source)
	local message = "Camera has been set up at"
	local color = {200, 0, 0}
    TriggerClientEvent('chatMessage', source, '', color, message)
    TriggerClientEvent('setRadar', source)
end