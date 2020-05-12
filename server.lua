RegisterServerEvent("DRP_Medic:ToggleDuty")
AddEventHandler("DRP_Medic:ToggleDuty", function(unemployed)
    local src = source
    local job = string.upper("EMS")
    local jobLabel = "Emergency Medical Technician"
    local characterInfo = exports["drp_id"]:GetCharacterData(source)
    local currentPlayerJob = exports["drp_jobcore"]:GetPlayerJob(src)
    local unemployed = unemployed
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

RegisterServerEvent("DRP_Medic:changeRank")
AddEventHandler("DRP_Medic:changeRank", function(dept,target,bool)
    local job = string.upper(dept)
    local characterInfo, currentPlayerJob = exports["drp_id"]:GetCharacterData(source), exports["drp_jobcore"]:GetPlayerJob(source)
    local targetName
    local src = source
    exports["externalsql"]:AsyncQueryCallback({
        query = "SELECT * FROM characters WHERE id = :charid",
        data = {
            charid = target
        }
    }, function(result)
        targetName = result.data[1].name
    end)
    if currentPlayerJob.job == job then
        exports["externalsql"]:AsyncQueryCallback({
            query = "SELECT * FROM medic WHERE `char_id` = :charid",
            data = {
                charid = characterInfo.charid
            }
        }, function(results)
            if results.data[1] ~= nil and results.data[1].rank >= 4 then
                    exports["externalsql"]:AsyncQueryCallback({
                        query = "SELECT * FROM medic WHERE `char_id` = :charid",
                        data = {
                            charid = target
                        }
                    }, function(results)
                        if results.data[1] ~= nil then
                        local rankvar
                        if bool then
                            rankvar = (results.data[1].rank+1)%5
                            exports["externalsql"]:AsyncQuery({
                                query = "UPDATE medic SET `rank` = :rank WHERE `char_id` = :charid",
                                data = {
                                    rank = rankvar,
                                    charid = target
                                }
                            })
                            --TriggerClientEvent("DRP_Core:Info",target,"EMS",tostring("You have been promoted to EMT grade "..rankvar), 4500, true, "leftCenter")
                            TriggerClientEvent("DRP_Core:Info",src,"EMS",tostring("You promoted "..targetName.." to rank "..rankvar), 4500, true, "leftCenter")
                        else
                            if results.data[1].rank == 1 then
                                exports["externalsql"]:AsyncQuery({
                                    query = "DELETE FROM medic WHERE `char_id` = :charid",
                                    data = {
                                        charid = target
                                    }
                                })
                                --TriggerClientEvent("DRP_Core:Info",target,"EMS",tostring("You have been fired"), 4500, true, "leftCenter")
                                TriggerClientEvent("DRP_Core:Info",src,"EMS",tostring("You fired "..targetName..""), 4500, true, "leftCenter")
                            else
                                rankvar = (results.data[1].rank-1)%5
                                exports["externalsql"]:AsyncQuery({
                                    query = "UPDATE medic SET `rank` = :rank WHERE `char_id` = :charid",
                                    data = {
                                        rank = rankvar,
                                        charid = target
                                    }
                                })
                                --TriggerClientEvent("DRP_Core:Info",target,"EMS",tostring("You have been demoted to EMT grade "..rankvar), 4500, true, "leftCenter")
                                TriggerClientEvent("DRP_Core:Info",src,"EMS",tostring("You demoted "..targetName.." to rank "..rankvar), 4500, true, "leftCenter")
                            end
                        end
                        end
                    end)
                --end
            end
        end)
    end
end)

RegisterServerEvent("DRP_Medic:hire")
AddEventHandler("DRP_Medic:hire", function(dept, target)
    local characterInfo = exports["drp_id"]:GetCharacterData(source)
    local targetName
    exports["externalsql"]:AsyncQueryCallback({
        query = "SELECT * FROM characters WHERE id = :charid",
        data = {
            charid = target
        }
    }, function(result)
        targetName = result.data[1].name
    end)
    local playerjob = exports["drp_jobcore"]:GetPlayerJob(source)
    local playerRank
    if playerjob.job == string.upper(dept) then
        exports["externalsql"]:AsyncQueryCallback({
            query = "SELECT * FROM medic WHERE char_id= :charid",
            data = {
                charid=characterInfo.charid
            }
        }, function(result)
            if result.data[1] ~= nil then
                playerRank = result.data[1].rank
            end
            if playerRank >= 4 then
                exports["externalsql"]:AsyncQuery({
                    query = "INSERT INTO medic VALUES (DEFAULT, 1, :targetid)",
                    data = {
                        targetid=target
                    }
                })
                --TriggerClientEvent("DRP_Core:Info", target, "Government", tostring("You are now an Emergency Medical Technician Grade 1"), 4000, true, "leftCenter")
            else 
                TriggerClientEvent("DRP_Core:Info", src, "EMS", tostring("You are not a high enough rank to hire people"), 4000, true, "leftCenter")
            end
        end)
    end
end)

RegisterServerEvent("DRP_Medic:PutInVehicle")
AddEventHandler("DRP_Medic:PutInVehicle", function(target)
    local src = source
    local srcJob = exports["drp_jobcore"]:GetPlayerJob(src)
    if srcJob.job == "EMS" and target ~= nil then
        TriggerClientEvent("DRP_Medic:PutInVehicle", target)
    elseif srcJob.job ~= "EMS" then
        TriggerClientEvent("DRP_Core:Warning",src,"Government", tostring("You are not an EMS"),4500,false,"leftCenter")
    else
        TriggerClientEvent("DRP_Core:Warning",src,"Government", tostring("No target found"),4500,false,"leftCenter")
    end
end)

RegisterServerEvent("DRP_Medic:OutOfVehicle")
AddEventHandler("DRP_Medic:OutOfVehicle", function(target)
    local src = source
    local srcJob = exports["drp_jobcore"]:GetPlayerJob(src)
    if srcJob.job == "EMS" and target ~= nil then
        TriggerClientEvent("DRP_Medic:PutInVehicle", target)
    elseif srcJob.job ~= "EMS" then
        TriggerClientEvent("DRP_Core:Warning",src,"Government", tostring("You are not an EMS"),4500,false,"leftCenter")
    else
        TriggerClientEvent("DRP_Core:Warning",src,"Government", tostring("No target found"),4500,false,"leftCenter")
    end
end)

RegisterServerEvent("DRP_Medic:revive")
AddEventHandler("DRP_Medic:revive", function(target)
    local playerjob = exports['drp_jobcore']:GetPlayerJob(source)
    if playerjob.job == "EMS" and target ~= 0 then
        TriggerClientEvent("DRP_Medic:compressions",source)
        Citizen.Wait(13500)
        TriggerClientEvent("DRP_Core:Revive",target)
    elseif playerjob.job ~= "EMS" then
        TriggerClientEvent("DRP_Core:Warning",source,"Government", tostring("You are not an EMS"),4500,false,"leftCenter")
    else
        TriggerClientEvent("DRP_Core:Warning",source,"Government", tostring("No target found"),4500,false,"leftCenter")
    end
end)

RegisterServerEvent("DRP_Medic:Revived")
AddEventHandler("DRP_Medic:Revived", function(boolValue)
    local src = source
    local character = exports["drp_id"]:GetCharacterData(src)
    local deadValue = 0
    -- Basic If Statement To Check Bool Value Status And Update Variable Where Needed --
    if boolValue then
        deadValue = 1
    else
        deadValue = 0
    end
    ------------------------------------------------------------------------------------
    exports["externalsql"]:AsyncQueryCallback({
        query = "UPDATE characters SET `isDead` = :deadValue WHERE `id` = :charid",
            data = {
                deadValue = deadValue,
                charid = character.charid
            }
        }, function(updateResults)
    end)
end)

RegisterServerEvent("DRP_Medic:heal")
AddEventHandler("DRP_Medic:heal", function(target)
    local playerjob = exports['drp_jobcore']:GetPlayerJob(source)
        if playerjob.job == "EMS" and target ~= 0 then
            TriggerClientEvent("DRP_Medic:heal",target)
        elseif playerjob.job ~= "EMS" then
            TriggerClientEvent("DRP_Core:Info",source,"Government",tostring("You are not an EMS"),4500,false,"leftCenter")
        else
            TriggerClientEvent("DRP_Core:Info",source,"Government", tostring("No target found"),4500,false,"leftCenter")
        end
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