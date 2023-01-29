local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

--[[
Citizen.CreateThread(function()
    while true do
        Wait(0)
        ped = PlayerPedId()
        SetPedInfiniteAmmo(ped, false, "weapon_revolver")
        SetPedInfiniteAmmo(ped, false, "weapon_appistol")
        SetPedInfiniteAmmo(ped, false, "weapon_combatpistol")
        SetPedInfiniteAmmo(ped, false, "weapon_assaultsmg")
        SetPedInfiniteAmmo(ped, false, "weapon_microsmg")
        SetPedInfiniteAmmo(ped, false, "weapon_pumpshotgun")
        SetPedInfiniteAmmo(ped, false, "weapon_marksmanrifle")
        SetPedInfiniteAmmo(ped, false, "WEAPON_PISTOL")
        SetPedInfiniteAmmo(ped, false, "weapon_machinepistol")
        SetPedInfiniteAmmo(ped, false, "WEAPON_HEAVYPISTOL")
        SetPedInfiniteAmmo(ped, false, "WEAPON_PISTOL50")
        SetPedInfiniteAmmo(ped, false, "WEAPON_GUSENBERG")
        SetPedInfiniteAmmo(ped, false, "WEAPON_SMG")
        SetPedInfiniteAmmo(ped, false, "WEAPON_MINISMG")
        SetPedInfiniteAmmo(ped, false, "WEAPON_ASSAULTRIFLE")
        SetPedInfiniteAmmo(ped, false, "weapon_carbinerifle")
        SetPedInfiniteAmmo(ped, false, "WEAPON_ADVANCEDRIFLE")
        SetPedInfiniteAmmo(ped, false, "WEAPON_BULLPUPRIFLE")
        SetPedInfiniteAmmo(ped, false, "WEAPON_KNIFE")
        SetPedInfiniteAmmo(ped, false, "WEAPON_BAT")
		SetPedInfiniteAmmo(ped, false, "weapon_heavyshotgun")
        SetPedInfiniteAmmo(ped, false, "weapon_compactrifle")
        SetPedInfiniteAmmo(ped, false, "WEAPON_COMBATPDW")
		Citizen.Wait(5000)
    end
end)
]]--


ESX = nil
local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

    ESX.TriggerServerCallback('grv_waffenshops:loadItems', function(items)
        for key, value in pairs(items) do
            AddItem(value.name, value.display, value.price)
        end
    end)
end)
	

local laden = {
	{x = 1693.4,    y = 3759.5,  z = 33.7},
	{x = 22.0,      y = -1107.2, z = 28.8}
}

local enableField = false

function toggleField(enable)
    SetNuiFocus(enable, enable)
    enableField = enable

    if enable then
        SendNUIMessage({
            action = 'open'
        }) 
    else
        SendNUIMessage({
            action = 'close'
        }) 
    end
end

RegisterNUICallback('escape', function(data, cb)
    toggleField(false)
    SetNuiFocus(false, false)

    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    local warenkorb = data.warenkorb
    local totalprice = 0

    for key, value in pairs(warenkorb) do
        totalprice = totalprice + value.price
    end

    local withTax = totalprice + (totalprice * 0.00)
    
    ESX.TriggerServerCallback('grv_waffenshops:canAfford', function(bool)
        if bool then
            ESX.ShowNotification(("~b~Du hast einen Einkauf für ~g~$%s ~b~getätigt."):format(withTax))
        else
            ESX.ShowNotification(("~b~Du kannst dir den Einkauf für ~r~$%s ~b~nicht leisten."):format(withTax))
        end
    end, withTax, warenkorb)

    cb('ok')
end)

function AddItem(name, display, price)
    SendNUIMessage({
        action = 'add',
        name = name,
        display = display,
        price = price
    })
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
		local canSleep = true

        for key, value in pairs(laden) do
            local dist = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), vector3(value.x, value.y, value.z))

            if dist <= 2.0 then
				canSleep = false
                ESX.ShowHelpNotification("Drücke ~w~[~b~E~w~] um den Waffenladen zu öffnen")

                if IsControlJustReleased(0, 38) then
                    toggleField(true)
                end
            end
        end
	
		if canSleep then 
			Citizen.Wait(500)
		end
    end
end)

Citizen.CreateThread(function()
    Wait(1000)
    for _, coords in pairs(laden) do
        local blip = AddBlipForCoord(vector3(coords.x, coords.y, coords.z))

        SetBlipSprite(blip, 110)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 0)
        SetBlipDisplay(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Waffenladen")
        EndTextCommandSetBlipName(blip)
    end
end)