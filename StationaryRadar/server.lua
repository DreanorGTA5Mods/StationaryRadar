AddEventHandler('chatMessage', function(source, n, message)
  local args = stringsplit(message, " ")
  if(message == "/set speedradar") then
	setupCamera(source)
  end
end)


function setupCamera (source)

local b = GET_ENTITY_COORDS(PlayerId(), true)
	local e = 'chatMessage'
	local mes = "SYSTEM"
	local m = "Camera has been set up at"..b
	local ms = {200, 0, 0}
    TriggerClientEvent(e, source, mes, ms, m)
end