RegisterServerEvent("DRP_Medic:ToggleDuty")
AddEventHandler("DRP_Medic:ToggleDuty", function(unemployed)
    local src = source
    local job = string.upper("EMS")
    local jobLabel = "Emergency Medical Technician"
    local characterInfo = exports["drp_id"]:GetCharacterData(source)
    local currentPlayerJob = exports["drp_jobcore"]:GetPlayerJob(src)
    local unemployed = unemployed
    print(tostring(currentPlayerJob).." "..tostring(characterInfo))
    ---------------------------------------------------------------------------
        if unemployed then
            if currentPlayerJob.job ~= "UNEMPLOYED" then
                exports["drp_jobcore"]:RequestJobChange(src, false, false, false)
                TriggerEvent("DRP_Clothing:RestartClothing", src)
            else
                TriggerClientEvent("DRP_Core:Error", src, "Job Manager", tostring("You're already not working"), 2500, true, "leftCenter")
            end
        else
            if currentPlayerJob.job == job then
                TriggerClientEvent("DRP_Core:Error", src, "Job Manager", tostring("You're already on duty"), 2500, true, "leftCenter")
            else
            if exports["drp_jobcore"]:DoesJobExist(job) then
                    exports["externalsql"]:AsyncQueryCallback({
                        query = "SELECT * FROM medic WHERE `char_id` = :charid",
                        data = {
                            charid = characterInfo.charid
                        }
                        }, function(jobResults)
                        if jobResults.data[1] ~= nil then
                            exports["drp_jobcore"]:RequestJobChange(src, job, jobLabel, {
                                rank = jobResults.data[1].rank,
                            })
                            TriggerClientEvent("DRP_Core:Info", src, "Government", tostring("Welcome "..jobLabel.." Grade "..jobResults.data[1].rank.." "..characterInfo.name..""), 4500, true, "leftCenter")
                        else
                            TriggerClientEvent("DRP_Core:Info", src, "Government", tostring("You must be hired as an Emergency Medical Technician to go on duty."), 4500, true, "leftCenter")
                        end
                    end)
                end
            end
        end
    end)


RegisterServerEvent("DRP_Medic:hire")
AddEventHandler("DRP_Medic:hire", function(target)
    local characterInfo = exports["drp_id"]:GetCharacterData(source)
    local playerjob = exports["drp_jobcore"]:GetPlayerJob(source)
    local playerRank, targetInfo
    local target = target
    if playerjob.job == "EMS" then
        exports["externalsql"]:AsyncQueryCallback({
            query = "SELECT * FROM medic WHERE `char_id`= :charid",
            data = {
                charid=characterInfo.charid
            }
        }, function(result)
            if result.data[1] ~= nil then
                playerRank = result.data[1].rank
            end
        end)
        if playerRank == 5 then
            exports["drp_jobcore"]:RequestJobChange(target,"EMS","Emergency Medical Technician",false)
            targetInfo = exports["drp_id"]:GetCharacterData(target)
            exports["externalsql"]:AsyncQuery({
                query = "INSERT INTO medic VALUES (DEFAULT, 1, :targetid)",
                data = {
                    targetid=targetInfo.charid
                }
            })
            TriggerClientEvent("DRP_Core:Info", target, "Government", tostring("You are now an Emergency Medical Technician Grade 1"), 4000, true, "leftCenter")
        else 
            TriggerClientEvent("DRP_Core:Info", src, "EMS", tostring("You are not a high enough rank to hire people"), 4000, true, "leftCenter")
        end
    end
end)

RegisterServerEvent("DRP_Medic:revive")
AddEventHandler("DRP_Medic:revive", function(target)
    local playerjob = exports['drp_jobcore']:GetPlayerJob(source)
    if playerjob.job == "EMS" and target ~= 0 then
        print("attempt to revive")
        print(target)
        TriggerClientEvent("DRP_Medic:revive",target)
    elseif playerjob.job ~= "EMS" then
        print("attempt to alert")
        TriggerClientEvent("DRP_Core:Info",source,"Government", tostring("You are not an EMS"),4500,false,"leftCenter")
    else
        TriggerClientEvent("DRP_Core:Info",source,"Government", tostring("No target found"),4500,false,"leftCenter")
    end
end)

RegisterServerEvent("DRP_Medic:heal")
AddEventHandler("DRP_Medic:heal", function(target)
    local playerjob = exports['drp_jobcore']:GetPlayerJob(source)
        if playerjob.job == "EMS" and target ~= 0 then
            TriggerClientEvent("DRP_Medic:heal",target)
            TriggerClientEvent("DRP_Core:Info",target,"EMS", tostring("You have been healed"),4500,false,"leftCenter")
        elseif playerjob.job ~= "EMS" then
            TriggerClientEvent("DRP_Core:Info",source,"Government",tostring("You are not an EMS"),4500,false,"leftCenter")
        else
            TriggerClientEvent("DRP_Core:Info",source,"Government", tostring("No target found"),4500,false,"leftCenter")
        end
end)

RegisterServerEvent("DRP_Medic:CheckEMSEscort")
AddEventHandler("DRP_Medic:CheckEMSEscort", function(targetPlayer)
    local src = source
    TriggerClientEvent("DRP_Medic:EscortToggle", targetPlayer, src)
end)

RegisterServerEvent("DRP_Medic:CallHandler")
AddEventHandler("DRP_Medic:CallHandler", function(coords, information)
    local src = source
    local players = GetPlayers()
    local myCharacterName = exports["drp_id"]:GetCharacterName(src)
    ---------------------------------------------------------------------------
    for a = 0, #players do
        local playersJobs = exports["drp_jobcore"]:GetPlayerJob(tonumber(players[a]))
        if playersJobs ~= false then
            if playersJobs.job == "EMS" then
                TriggerClientEvent("DRP_Core:Info", src, "Call Handler", tostring("Thank you for your call, an ambulance will be contacted and we will get back to you"), 7500, false, "rightCenter")
                TriggerClientEvent("DRP_Core:Warning", tonumber(players[a]), "EMS Call", tostring("A new call has come from "..information), 7500, false, "rightCenter")
                TriggerClientEvent("DRP_Medic:AwaitingCall", tonumber(players[a]), coords)
            end
        end
    end
end)