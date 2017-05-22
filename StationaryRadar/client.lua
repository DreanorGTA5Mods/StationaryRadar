RegisterNetEvent('setRadar')
local speedcam;

AddEventHandler('setRadar', function()
	speedcam = GetEntityCoords(GetPlayerPed(-1))
	--GetPlayerPed(PlayerId())
    TriggerEvent("chatMessage", "[System]", { 255,0,0}, "Radar set at".." x: "..pos['x']) 
end)

Citizen.CreateThread(function()
	while true do
		Wait(0)		
		if speedcam ~=nil then
			local pos = GetEntityCoords(GetPlayerPed(-1))
			if pos['x'] +5 >= speedcam['x'] then -- get radius of area in which people will get busted
				TriggerEvent("chatMessage", "[System]", { 255,0,0}, "speeding"..pos['x']) 
			end
		end
	 end  
end)