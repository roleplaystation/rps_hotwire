--[[ Config Here ]]
local Radio = false -- Radio On/ Off after the engine starts
local Time = 10 * 1000 -- Time for each stage (ms)

--[[ Hotwire Anim --]]
local animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@"
local anim = "machinic_loop_mechandplayer"
local flags = 49

--[[ Load Anim Dict Function --]]
function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

local vehicle
function disableEngine()
	Citizen.CreateThread(function()
		while hotwiring do
			SetVehicleEngineOn(vehicle, false, true, false)
			if not hotwiring then
				break
			end
			Citizen.Wait(0)
		end
	end)
end

--[[ NUI progressBar
Thanks to https://github.com/chipsahoy6/progressBars --]]
function startUI(time, text, bgcolor) 
	local dcolor = 'rgba(179, 57, 57,0.7)'
	if bgcolor then
		dcolor = bgcolor
	end
	SendNUIMessage({
		type = "ui",
		display = true,
		time = time,
		text = text,
		color = dcolor
	})
end

--[[ Main Thread --]]
Citizen.CreateThread(function()
	local player_entity = PlayerPedId()
	while true do
		Citizen.Wait(0)
		if GetSeatPedIsTryingToEnter(player_entity) == -1 then
	                Citizen.Wait(10)
			vehicle = GetVehiclePedIsTryingToEnter(player_entity)
			if IsVehicleNeedsToBeHotwired(vehicle) then
				disableEngine()
				hotwiring = true
				loadAnimDict(animDict)
				Citizen.Wait(7000)
				ClearPedTasks(player_entity)
				TaskPlayAnim(player_entity, animDict, anim, 3.0, 1.0, -1, flags, 1, 0, 0, 0)
				if hotwiring then
					startUI(Time, "Hotwire Stage 1", "rgba(194, 54, 22,0.7)")
					Citizen.Wait(Time+500)	
					startUI(Time, "Hotwire Stage 2", "rgba(232, 65, 24,0.7)")
					Citizen.Wait(Time+500)
				end
				if GetVehiclePedIsIn(player_entity, false) == vehicle then
					hotwiring = false
					StopAnimTask(player_entity, animDict, anim, 1.0)
					Citizen.Wait(1000)
					SetVehicleEngineOn(vehicle, true, true, false)
					SetVehicleJetEngineOn(vehicle, true)
					RemoveAnimDict(animDict)
					if not Radio then
						SetVehicleRadioEnabled(vehicle, false)
					end
				end
			end
		end
	end
end)
