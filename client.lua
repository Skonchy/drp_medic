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
    local target = args[1]
    if target then
        TriggerServerEvent("DRP_Medic:hire",target)
    else
        TriggerEvent("DRP_Core:Info", "Hire", tostring("Target does not exist"),7000,false,"leftCenter")
    end
end,false)

RegisterCommand("revive", function(source,args,raw)
    local target, distance = GetClosestPlayer()
    local targetPlayer = GetPlayerServerId(target)
    print(distance)
    print(tostring(targetPlayer))
    print(tostring(IsPedDeadOrDying(targetPlayer,1)))
    if distance ~= nil and distance < 3 and IsPedDeadOrDying(targetPlayer,1) then
        TaskStartScenarioInPlace(playerPed, "CPR_PUMPCHEST", 0, true)
        TriggerServerEvent("DRP_Medic:revive",targetPlayer)
    else
        TriggerEvent("DRP_Core:Info", "Revive", tostring("No dead persons near you"), 7000, false, "leftCenter")
    end
end,false)

RegisterCommand("heal", function(source,args,raw)
    local target, distance = exports["drp_core"]:GetClosestPlayer()
    if distance ~= nil and distance < 3 then
        TriggerServerEvent("DRP_Medic:heal",GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Info", "Heal", tostring("No persons near you"), 7000, false, "leftCenter")
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
    local target, distance = exports["drp_core"]:GetClosestPlayer()
    if distance ~= -1 and distance < 3 then
        TriggerServerEvent("DRP_Medic:CheckEMSEscort", GetPlayerServerId(target))
    else
        TriggerEvent("DRP_Core:Info", "Drag", tostring("No Persons Near You"), 7000, false, "leftCenter")
    end
end,false)

RegisterNetEvent("DRP_Medic:revive")
AddEventHandler("DRP_Medic:revive", function()
    local playerPed = PlayerPedId()
    Citizen.Wait(10000)
    ClearPedTasks(playerPed)
    ResurrectPed(playerPed)
    ClearPedTasksImmediately(playerPed)
    local playerPedPos = GetEntityCoords(playerPed, false)
    SetEntityCoords(playerPed, playerPedPos.x, playerPedPos.y, playerPedPos.z + 0.3, 0.0, 0.0, 0.0, 0)
end)

RegisterNetEvent("DRP_Medic:heal")
AddEventHandler("DRP_Medic:heal", function(target)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    SetEntityHealth(playerPed,maxHealth)
    TriggerEvent("DRP_Core:Info", "Heal", tostring("Healed"), 7000, false, "leftCenter")
end)

RegisterNetEvent("DRP_Medic:EscortToggle")
AddEventHandler("DRP_Medic:EscortToggle", function(target)
	if not IsPedSittingInAnyVehicle(target) then
		drag = not drag
		officerDrag = target
	end
end)

RegisterNetEvent("DRP_Medic:AwaitingCall")
AddEventHandler("DRP_Medic:AwaitingCall", function(coords)
    callActive = true
    target.pos = coords
    SendNotification("Press ~g~E~s~ to accept call or press ~g~X~s~ to refuse call")
    PlaySoundFrontend(-1, "TENNIS_POINT_WON", "HUD_AWARDS")
end)

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
            print(target.pos)
            local dist = Vdist(playerPos.x,playerPos.y,playerPos.z,target.pos.x,target.pos.y,target.pos.z)
            if dist < 3 then
                RemoveBlip(target.blip)
            end
        end
        Citizen.Wait(0)
    end
end)

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