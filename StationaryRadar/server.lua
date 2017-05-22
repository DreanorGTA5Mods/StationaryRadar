AddEventHandler('chatMessage', function(source, n, message)
  -- todo only for cops
  if(message == "/set speedradar") then
	setupCamera(source)
  end
end)

function setupCamera (source)
	local b = GET_ENTITY_COORDS(PlayerId(), true)
	local message = "Camera has been set up at"..b
	local color = {200, 0, 0}
    TriggerClientEvent('chatMessage', source, '', color, message)
end