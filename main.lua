local VORPcore = exports.vorp_core:GetCore()
local talktoprompt = GetRandomIntInRange(0, 0xffffff)
local decision = GetRandomIntInRange(0, 0xffffff)
local progressbar = exports.vorp_progressbar:initiate()


TriggerEvent("getCore",function(core)
    VORPcore = core
end)

RegisterNetEvent("vorp:SelectedCharacter") -- NPC loads after selecting character
AddEventHandler("vorp:SelectedCharacter", function(charid)
StartNPCs()
end)

function StartNPCs() --start function after user selected the character
    for i, v in ipairs(Config.NPCs) do
        local x, y, z = table.unpack(v.coords)
        local hashModel = GetHashKey(v.npcmodel) -- Loading Model
        if IsModelValid(hashModel) then
            RequestModel(hashModel)
            while not HasModelLoaded(hashModel) do
                Wait(100)
            end
        else
            print(v.npcmodel .. " is not valid")
        end
        local npc = CreatePed(hashModel, x, y, z, v.heading, false, true, true, true) -- Spawn NPC Ped
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
        SetEntityCanBeDamaged(npc, false) --npc can't be damaged
        SetEntityInvincible(npc, true)
        Wait(1000)
        FreezeEntityPosition(npc, true) -- NPC can't escape
        SetBlockingOfNonTemporaryEvents(npc, true) -- NPC can't be scared
        if v.blip ~= 0 then --create blip
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
            SetBlipSprite(blip, v.blip, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.npc_name)
        end
        if v.scenario then --load scenario in loop
            TaskStartScenarioInPlace(npc, GetHashKey(v.scenario), 0, true, false, false, false)
        end
        if v.anim.animDict and v.anim.animName then --loads animation looped
            RequestAnimDict(v.anim.animDict)
            while not HasAnimDictLoaded(v.anim.animDict) do --get animation
                Citizen.Wait(100)
            end
            TaskPlayAnim(npc, v.anim.animDict, v.anim.animName, 1.0, -1.0, -1, 1, 0, true, 0, false, 0, false)
        end
    end
end

Citizen.CreateThread(function() --creating npc interaction prompts
    Citizen.Wait(5000)
    talktonpc = PromptRegisterBegin()
    PromptSetControlAction(talktonpc, Config.keys["G"])
    talkLabel = CreateVarString(10, 'LITERAL_STRING', Config.Language.press)
    PromptSetText(talktonpc, talkLabel)
    PromptSetEnabled(talktonpc, 1)
    PromptSetVisible(talktonpc, 1)
    PromptSetStandardMode(talktonpc, 1)
    PromptSetGroup(talktonpc, talktoprompt)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, talktonpc, true)
    PromptRegisterEnd(talktonpc)

    noPrompt = PromptRegisterBegin()
    PromptSetControlAction(noPrompt, Config.keys["DOWN"]) 
    noLabel = CreateVarString(10, 'LITERAL_STRING', Config.Language.noLabel)
    PromptSetText(noPrompt, noLabel)
    PromptSetEnabled(noPrompt, 1)
    PromptSetVisible(noPrompt, 1)
    PromptSetStandardMode(noPrompt, 1)
    PromptSetGroup(noPrompt, decision)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, noPrompt, true)
    PromptRegisterEnd(noPrompt)

    yesPrompt = PromptRegisterBegin()
    PromptSetControlAction(yesPrompt, Config.keys["UP"]) 
    yesLabel = CreateVarString(10, 'LITERAL_STRING', Config.Language.yesLabel)
    PromptSetText(yesPrompt, yesLabel)
    PromptSetEnabled(yesPrompt, 1)
    PromptSetVisible(yesPrompt, 1)
    PromptSetStandardMode(yesPrompt, 1)
    PromptSetGroup(yesPrompt, decision)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, yesPrompt, true)
    PromptRegisterEnd(yesPrompt)
end)

local talking = false
Citizen.CreateThread(function()
    while true do
        local sleep = true
        local _source = source
        for i, v in ipairs(Config.NPCs) do --check every npc
            local playerCoords = GetEntityCoords(PlayerPedId())
            if Vdist(playerCoords, v.coords) <= v.radius and not talking then -- Checking distance between player and npc
                if v.type ~= "nointeraction" then
                    sleep = false
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.Language.talk)
                    PromptSetActiveGroupThisFrame(talktoprompt, label) --loads talktoNPC prompt
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, talktonpc) then --when button is pressed
                        local playerPed = PlayerPedId()
                        talking = true
                    end
                end
            elseif Vdist(playerCoords, v.coords) <= v.radius and talking then --if talking to a npc, show decision
                if v.type == "give" then
                    sleep = false
                    FreezeEntityPosition(playerPed,true) --player cant move while performing animation
                    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), Config.taskbar, true, false, false, false) --Taskbar-Animation (change the text in "" if u want to have another animation instead)
                    progressbar.start(Config.Language.getting_item, Config.taskbar, nil, linear)
                    Citizen.Wait(Config.taskbar)
                    TriggerServerEvent("juSa_npc_rewards:give", v.giveitem, v.givemoney) -- give item/money
                    if v.usewebhook then
                        local type = "give"
                        Citizen.Wait(500)
                        TriggerServerEvent("juSa_npc_rewards:discord", type, v.giveitem, v.givemoney) --webhook trigger
                    end
                    talking = false
                elseif v.type == "sell" then
                    sleep = false
                    local itemInfo = ""
                    for _, item in ipairs(v.takeitem) do
                        itemInfo = itemInfo .. tostring(item.amount) .. "x " .. item.label .. ", "
                    end
                    itemInfo = string.sub(itemInfo, 1, -3)  -- removes trailing comma and space
                    local info = string.format(Config.Language.sellinfo, itemInfo, v.givemoney)

                    local label = CreateVarString(10, 'LITERAL_STRING', info)
                    PromptRemoveGroup(talktoprompt) --unload talktonpc prompt
                    PromptSetActiveGroupThisFrame(decision, label) --loads decision prompt
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, yesPrompt) then
                        TriggerServerEvent("juSa_npc_rewards:infosell", v.takeitem, v.givemoney, v.taskbar, v.usewebhook)
                        Wait(v.taskbar)
                        talking = false
                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, noPrompt) then
                        PromptRemoveGroup(decision)
                        VORPcore.NotifyBottomRight(Config.Language.seeUlater,4000)
                        Wait(4000)
                        talking = false
                    end
                elseif v.type == "exchange" then
                    sleep = false
                    local takeItemInfo = ""
                    for _, item in ipairs(v.takeitem) do
                        takeItemInfo = takeItemInfo .. tostring(item.amount) .. "x " .. item.label .. ", "
                    end
                    takeItemInfo = string.sub(takeItemInfo, 1, -3)  -- Remove the trailing comma and space

                    local giveItemInfo = ""
                    for _, item in ipairs(v.giveitem) do
                        giveItemInfo = giveItemInfo .. tostring(item.amount) .. "x " .. item.label .. ", "
                    end
                    giveItemInfo = string.sub(giveItemInfo, 1, -3)  -- Remove the trailing comma and space
                    local info = string.format(Config.Language.exchangeinfo, takeItemInfo, v.takemoney, giveItemInfo, v.givemoney)
                    local label = CreateVarString(10, 'LITERAL_STRING', info)
                    PromptRemoveGroup(talktoprompt) --unload talktonpc prompt
                    PromptSetActiveGroupThisFrame(decision, label) --loads decision prompt
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, yesPrompt) then
                        TriggerServerEvent("juSa_npc_rewards:infoexchange", v.giveitem, v.takeitem, v.givemoney, v.takemoney, v.taskbar, v.usewebhook)
                        Wait(v.taskbar)
                        talking = false
                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, noPrompt) then
                        PromptRemoveGroup(decision)
                        VORPcore.NotifyBottomRight(Config.Language.seeUlater,4000)
                        Wait(4000)
                        talking = false
                    end
                end
                ClearPedTasks(playerPed)
                FreezeEntityPosition(playerPed,false)
                PromptRemoveGroup(talktoprompt)
                PromptRemoveGroup(decision)
            end
        end
        if sleep then
            Citizen.Wait(500)
        end
        Citizen.Wait(1)
    end
end)

RegisterNetEvent("juSa_npc_rewards:infosellsend")
AddEventHandler("juSa_npc_rewards:infosellsend", function( takeitem, givemoney, taskbar, usewebhook)
    FreezeEntityPosition(playerPed,true)
    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), taskbar, true, false, false, false)
    progressbar.start(Config.Language.selling_item, taskbar, nil, linear)
    Citizen.Wait(taskbar)
    TriggerServerEvent("juSa_npc_rewards:sell", takeitem, givemoney)
    if usewebhook then
        local type = "sell"
        TriggerServerEvent("juSa_npc_rewards:discord", type, takeitem, givemoney)
    end
end)

RegisterNetEvent("juSa_npc_rewards:infoexchangesend")
AddEventHandler("juSa_npc_rewards:infoexchangesend", function(takeitem, giveitem, givemoney, takemoney, taskbar, usewebhook)
    FreezeEntityPosition(playerPed,true)
    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), Config.taskbar, true, false, false, false)
    progressbar.start(Config.Language.exchanging_item, Config.taskbar, nil, linear)
    Citizen.Wait(Config.taskbar)
    TriggerServerEvent("juSa_npc_rewards:exchange", giveitem, takeitem, givemoney, takemoney)
    if usewebhook then
        local type = "exchange"
        TriggerServerEvent("juSa_npc_rewards:discord", type, giveitem, takeitem, givemoney, takemoney)
    end
end)
