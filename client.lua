--Script needs to alert all players with medic job when someone dies
--Allow medic leader to hire more medics
--Allow medics to revive and heal
--turn off auto healing
--Allow medics to load dead into ambulance

local drag = false
local officerDrag = -1
local callActive, onCall = false
local haveTarget = false
local target = {}

function SendNotification(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

RegisterCommand("onduty", function(source,args,raw)
    local job = args[1]
    TriggerServerEvent("DRP_Medic:ToggleDuty", false)
end,false)

RegisterCommand("offduty", function(source,args,raw)
    local job = args[1]
    TriggerServerEvent("DRP_Medic:ToggleDuty", true)
end,false)

RegisterCommand("hire", function(source,args,raw)
    local target = args[2]
    local dept = args[1]
    if target then
        TriggerServerEvent("DRP_Medic:hire",dept,target)
    else
        TriggerEvent("DRP_Core:Info", "Hire", tostring("Target does not exist"),5500,false,"leftCenter")
    end
end,false)

RegisterCommand("promote", function(source,args,raw)
    local target = args[2]
    local dept = args[1]
    if target then
        TriggerServerEvent("DRP_Medic:changeRank", dept, target, true)
    end
end, false)

RegisterCommand("demote",function(source,args,raw)
    local target = args[2]
    local dept = args[1]
    if target then
        TriggerServerEvent("DRP_Medic:changeRank", dept, target, false)
    end
end, false)

RegisterCommand("revive", function(source,args,raw)
    local target, distance = GetClosestPlayer()
    local targetPlayer = GetPlayerServerId(target)
    local playerPed = PlayerPedId()
    if distance ~= nil and distance < 3 and IsPedDeadOrDying(targetPlayer,1) then
        TriggerServerEvent("DRP_Medic:revive",targetPlayer)
    else
        TriggerEvent("DRP_Core:Info", "EMS", tostring("No dead persons near you"), 7000, false, "leftCenter")
    end
end,false)

RegisterCommand("heal", function(source,args,raw)
    local target, distance = GetClosestPlayer()
    if distance ~= nil and distance < 3 then
        TriggerServerEvent("DRP_Medic:heal",GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Info", "EMS", tostring("No persons near you"), 7000, false, "leftCenter")
    end
end,false)

RegisterCommand("911", function(source, args, raw)
    local src = source
    local callTarget = args[1]
    local callInformation = table.concat(args, ' ', 2, #args)
    local coords = GetEntityCoords(GetPlayerPed(PlayerId()))
    if callInformation ~= nil then
        if callTarget == "ems" then
            TriggerServerEvent("DRP_Medic:CallHandler", {x = coords.x, y = coords.y , z = coords.z}, callInformation)
        end
    end
end,false)

RegisterCommand("drag", function()
    local target, distance = GetClosestPlayer()
    if distance ~= nil and distance < 3 then
        TriggerServerEvent("DRP_Police:CheckLEOEscort",GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Warning", "EMS", tostring("No Persons Near You"), 7000, false, "leftCenter")
    end
end,false)

RegisterCommand("loadin", function()
    local target, distance = GetClosestPlayer()
    if distance ~= nil and distance < 3 then
        --TriggerServerEvent("DRP_Police:CheckLEOEscort",GetPlayerServerId(target))
        TriggerServerEvent("DRP_Medic:PutInVehicle",GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Warning", "EMS", tostring("No Persons Near You"), 7000, false, "leftCenter")
    end
end)

RegisterCommand("unload", function()
    local target, distance = GetClosestPlayer()
    if distance ~= nil and distance < 7 then
        TriggerServerEvent("DRP_Medic:OutOfVehicle", GetPlayerServerId(target))
    end
end)

RegisterNetEvent("DRP_Medic:compressions")
AddEventHandler("DRP_Medic:compressions", function()
    local playerPed = PlayerPedId()
    local lib, anim = 'mini@cpr@char_a@cpr_str', 'cpr_pumpchest'
        for i=1,15 do
            Citizen.Wait(900)
            RequestAnimDict(lib)
            TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0.0, false, false, false)
        end
        ClearPedTasks(playerPed)
end)

RegisterNetEvent("DRP_Medic:revive")
AddEventHandler("DRP_Medic:revive", function()
    local playerPed = PlayerPedId()
    ResurrectPed(playerPed)
    ClearPedTasksImmediately(playerPed)
    local playerPedPos = GetEntityCoords(playerPed, false)
    SetEntityCoords(playerPed, playerPedPos.x, playerPedPos.y, playerPedPos.z + 0.3, 0.0, 0.0, 0.0, 0)
    TriggerServerEvent("DRP_Medic:Revived", false)
end)

RegisterNetEvent("DRP_Medic:heal")
AddEventHandler("DRP_Medic:heal", function(target)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    SetEntityHealth(playerPed,maxHealth)
    ClearPedBloodDamage(playerPed)
    TriggerEvent("DRP_Core:Info", "Heal", tostring("You have been healed"), 7000, false, "leftCenter")
end)

RegisterNetEvent("DRP_Medic:AwaitingCall")
AddEventHandler("DRP_Medic:AwaitingCall", function(coords)
    callActive = true
    target.pos = coords
    SendNotification("Press ~g~E~s~ to accept call or press ~g~X~s~ to refuse call")
    PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS")
end)

RegisterNetEvent("DRP_Medic:PutInVehicle")
AddEventHandler("DRP_Medic:PutInVehicle", function()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    if IsAnyVehicleNearPoint(coords,5.0) then
        local vehicle = GetClosestVehicle(coords,5.0,0,71)
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        local freeSeat
        for i=maxSeats - 1, 0 , -1 do
            if IsVehicleSeatFree(vehicle, i) then
                freeSeat = i
                break
            end
        end
        if freeSeat then
            TaskWarpPedIntoVehicle(player,vehicle,freeSeat)
        else
            TriggerEvent("DRP_Core:Warning","EMS",tostring("No available seats in vehicle"), 5500, false, "leftCenter")
        end
    end
end)

RegisterNetEvent("DRP_Medic:OutVehicle")
AddEventHandler("DRP_Medic:OutVehicle", function()
    local playerPed = PlayerPedId()
	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		TaskLeaveVehicle(playerPed, vehicle, 16)
	end
end)

RegisterNetEvent("DRP_Medic:SpawnVehicle")
AddEventHandler("DRP_Medic:SpawnVehicle", function(coords)
    local ped = PlayerPedId()
    local ambulance = SpawnCar(coords)
    SetPedIntoVehicle(ped,ambulance,-1)
end)


-- 911 Calls Thread -- 
Citizen.CreateThread(function()
    while true do 
        if IsControlJustPressed(1, 38) and callActive then
            target.blip = AddBlipForCoord(target.pos.x, target.pos.y, target.pos.z)
            SetBlipSprite(target.blip, 310)
            SetBlipRoute(target.blip, true)
            haveTarget = true
            callActive = false
            onCall = true
            SendNotification("Call Accepted")
        elseif IsControlJustPressed(1, 73) and callActive then
            SendNotification("Refused Call")
            callActive = false
        end
        if onCall then
            local playerPos = GetEntityCoords(PlayerPedId())
            local dist = Vdist(playerPos.x,playerPos.y,playerPos.z,target.pos.x,target.pos.y,target.pos.z)
            if dist < 3 then
                RemoveBlip(target.blip)
            end
        end
        Citizen.Wait(0)
    end
end)

-- Sign On/Off --
Citizen.CreateThread(function()
    local sleepTimer = 1000
    while true do
        for a = 1, #DRPMedicJob.SignOnAndOff do
        local ped = PlayerPedId()
        local pedPos = GetEntityCoords(ped)
        local distance = Vdist(pedPos.x, pedPos.y, pedPos.z, DRPMedicJob.SignOnAndOff[a].x, DRPMedicJob.SignOnAndOff[a].y, DRPMedicJob.SignOnAndOff[a].z)
            if distance <= 5.0 then
                sleepTimer =  5
                exports['drp_core']:DrawText3Ds(DRPMedicJob.SignOnAndOff[a].x, DRPMedicJob.SignOnAndOff[a].y, DRPMedicJob.SignOnAndOff[a].z, tostring("~b~[E]~w~ to sign on duty or ~r~[X]~w~ to sign off duty"))
                if IsControlJustPressed(1, 86) then
                    TriggerServerEvent("DRP_Medic:ToggleDuty", false)
                elseif IsControlJustPressed(1, 73) then
                    TriggerServerEvent("DRP_Medic:ToggleDuty", true)
                end
            else
                sleepTimer = 1000
            end
        end
        Citizen.Wait(sleepTimer)
    end
end)
-- Garage Zones --
Citizen.CreateThread(function()
    local sleepTimer=1000
    while true do
        for a=1, #DRPMedicJob.Garages do
            local ped = PlayerPedId()
            local pedPos = GetEntityCoords(ped)
            local distance = Vdist(pedPos.x,pedPos.y,pedPos.z, DRPMedicJob.Garages[a].x, DRPMedicJob.Garages[a].y, DRPMedicJob.Garages[a].z)
            if distance <= 5.0 then
               sleepTimer = 5
               exports['drp_core']:DrawText3Ds(DRPMedicJob.Garages[a].x, DRPMedicJob.Garages[a].y, DRPMedicJob.Garages[a].z, tostring("~b~[E]~w~ to spawn an ambulance ~r~[X]~w~ to delete your ambulance"))
               if IsControlJustPressed(1,86) then
                TriggerServerEvent("DRP_Medic:SpawnVehicle",DRPMedicJob.CarSpawns[a])
               elseif IsControlJustPressed(1,73) then
                DeleteVehicle(GetVehiclePedIsIn(ped,true))
               end
            end
        end
        Citizen.Wait(sleepTimer)
    end
end)
-- Hospital Blips --
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(vector3(307.7, -1433.4, 28.9))
    SetBlipSprite(blip, 61)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Hospital')
	EndTextCommandSetBlipName(blip)
end)
-- Functions -- 
function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply)
    
    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value))
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end
---------------------------------------------------------------------------
function GetPlayers()
    return GetActivePlayers()
end

function RespawnPed(ped, coords, heading)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
end

function SpawnCar(coords)
    local hash = GetHashKey("ambulance")
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        RequestModel(hash)
        Citizen.Wait(0)
    end
    return CreateVehicle(hash, coords.x,coords.y,coords.z,coords.h,true,false)
end