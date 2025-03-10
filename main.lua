local Core = exports.vorp_core:GetCore()
local talktoprompt = GetRandomIntInRange(0, 0xffffff)
local decision = GetRandomIntInRange(0, 0xffffff)
local progressbar = exports.vorp_progressbar:initiate()
local Menu = exports.vorp_menu:GetMenuData()

local StartNPCsOnce = false
local generalCooldown = Config.Cooldown
local npcCooldowns = {} --table for every NPC if generalCooldown = false
local jobs = {}
local hasjob = false
local talking = false
local talkingTime = Config.talkingTime --sec how long you are "talkin"
local MenuTriggered = false
local WeaponChoosed = false
local selectedWeapon = nil
local WeaponID = nil

function StartNPCs() --start function after user selected the character
    Citizen.Wait(1000)
    for i, v in ipairs(Config.NPCs) do
        local x, y, z = table.unpack(v.coords)
        local hashModel = GetHashKey(v.npcmodel) -- loading NPC skin
        if IsModelValid(hashModel) then
            RequestModel(hashModel)
            while not HasModelLoaded(hashModel) do
                Wait(100)
            end
        else
            print(v.npcmodel .. " is not valid")
        end
        local npc = CreatePed(hashModel, x, y, z, v.heading, false, true, true, true) -- spawn NPC
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
        SetEntityCanBeDamaged(npc, false) --NPC can't be damaged
        SetEntityInvincible(npc, true)
        Wait(1000)
        FreezeEntityPosition(npc, true) -- NPC can't escape
        SetBlockingOfNonTemporaryEvents(npc, true) -- NPC can't be scared
        if not Config.generalCooldown then -- set cooldown for every NPC
            if v.cooldown ~= nil then
                npcCooldowns[i] = v.cooldown
            else
                npcCooldowns[i] = 0 
            end
            if Config.Debug then --if debug = true print cooldowns on start
                print("Loading NPC:", v.npc_name, "Cooldown:", v.cooldown)
            end
        else
            npcCooldowns[i] = Config.Cooldown
            if Config.Debug then 
                print("Loading NPC:", v.npc_name, "Cooldown = general Cooldown")
            end
        end
        if v.blip ~= 0 then --create blip
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
            SetBlipSprite(blip, v.blip, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.npc_name)
        end
        if v.scenario then --start scenario in place and loop it
            TaskStartScenarioInPlace(npc, GetHashKey(v.scenario), 0, true, false, false, false)
        end
        if v.anim.animDict and v.anim.animName then --play animation in loop
            RequestAnimDict(v.anim.animDict)
            while not HasAnimDictLoaded(v.anim.animDict) do
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

Citizen.CreateThread(function()
    while true do
        if LocalPlayer.state.IsInSession then
            if not StartNPCsOnce then --loading NPCs once if player choosed a char and joins game-session
                if Config.Debug then
                    print("Player joind game-session. Starting NPCs ...")
                end
                StartNPCs()
                StartNPCsOnce = true
            end
        end
        local sleep = true
        local _source = source
        for i, v in ipairs(Config.NPCs) do --check every NPC
            local playerCoords = GetEntityCoords(PlayerPedId())
            if Vdist(playerCoords, v.coords) <= v.radius and not talking then -- checking distance between player and NPC
                if v.type ~= "nointeraction" then
                    sleep = false
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.Language.talk)
                    PromptSetActiveGroupThisFrame(talktoprompt, label) --loads talktoNPC prompt
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, talktonpc) then --when button is pressed
                        if (generalCooldown > 0 and Config.generalCooldown) or (npcCooldowns[i] > 0 and v.cooldown ~= nil) then
                            PromptRemoveGroup(talktoprompt)
                            Core.NotifyBottomRight(Config.Language.onCooldown, 4000)
                            Wait(4000)
                        else
                            talking = true
                            talkingTime = Config.talkingTime
                        end
                        if v.joblocked and #v.joblocked > 0 then --if joblocked has at least 1 entry then
                            jobs = v.joblocked
                            TriggerServerEvent("juSa_npc_rewards:jobcheck", jobs) --check the jobs
                            while hasjob == nil do
                                Wait(10) 
                            end
                            if Config.Debug then
                                print("You need: ")
                                for i, job in ipairs(jobs) do
                                    if job and job.name then
                                        print("Job " .. i .. ": " .. job.name .. ", Grade: " .. tostring(job.grade))
                                    else
                                        print("Job " .. i .. " is nil or has no valid job name.")
                                    end
                                end
                            end
                            Wait(100)
                            if not hasjob then --wait for results and if player has not correct job he can not talk to NPC
                                talking = false
                                PromptRemoveGroup(talktoprompt)
                                Core.NotifyBottomRight(Config.Language.wrongJob, 4000)
                                Wait(4000)
                            end
                        elseif v.joblocked == nil then --if no job required
                            hasjob = true
                        end
                    end
                end
            elseif Vdist(playerCoords, v.coords) <= v.radius and talking and hasjob then --if talking to a NPC, show decision
                if v.type == "give" then
                    sleep = false
                    local playerPed = PlayerPedId()
                    FreezeEntityPosition(playerPed,true) --player cant move while performing animation
                    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_BADASS"), v.taskbar, true, false, false, false) --Taskbar-Animation (change the text in "" if u want to have another animation instead)
                    progressbar.start(Config.Language.getting_item, v.taskbar, nil, linear)
                    Citizen.Wait(v.taskbar)
                    TriggerServerEvent("juSa_npc_rewards:give", v.giveitem, v.givemoney, v.giveweapon, v.usewebhook, v.npc_name) -- give item/money
                    ClearPedTasks(playerPed)
                    FreezeEntityPosition(playerPed,false)
                    Reset()
                    if Config.generalCooldown then
                        NewCooldowns()
                    else
                        npcCooldowns[i] = v.cooldown or 0
                    end
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
                        TriggerServerEvent("juSa_npc_rewards:infosell", v.takeitem, v.givemoney, v.taskbar, v.usewebhook, v.npc_name)
                        Wait(v.taskbar)
                        Reset()
                        if Config.generalCooldown then
                            NewCooldowns()
                        else
                            npcCooldowns[i] = v.cooldown or 0
                        end
                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, noPrompt) then
                        PromptRemoveGroup(decision)
                        Core.NotifyBottomRight(Config.Language.seeUlater,4000)
                        Wait(4000)
                        Reset()
                    end
                elseif v.type == "exchange" then
                    sleep = false
                    local takeItemInfo = ""
                    if v.takeitem and #v.takeitem > 0 then
                        for _, item in ipairs(v.takeitem) do
                            takeItemInfo = takeItemInfo .. tostring(item.amount) .. "x " .. item.label .. ", "
                        end
                    else
                        takeItemInfo = Config.Language.noitemneeded
                    end
                    takeItemInfo = string.sub(takeItemInfo, 1, -3)  -- remove the trailing comma and space
                    local giveItemInfo = ""
                    if v.giveitem and #v.giveitem > 0 then
                        for _, item in ipairs(v.giveitem) do
                            giveItemInfo = giveItemInfo .. tostring(item.amount) .. "x " .. item.label .. ", " 
                        end 
                    else
                        giveItemInfo = Config.Language.noitemrec
                    end
                    if not v.giveweapon == nil then  -- check if giveweapon has items
                        for _, weapon in ipairs(v.giveweapon) do
                            giveItemInfo = giveItemInfo .. "1x " .. weapon.label .. ", "
                        end
                    end
                    giveItemInfo = string.sub(giveItemInfo, 1, -3) 
                    local info = string.format(Config.Language.exchangeinfo, takeItemInfo, v.takemoney, giveItemInfo, v.givemoney)
                    local label = CreateVarString(10, 'LITERAL_STRING', info)
                    PromptRemoveGroup(talktoprompt) --unload talktonpc prompt
                    PromptSetActiveGroupThisFrame(decision, label) --loads decision prompt
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, yesPrompt) then
                        TriggerServerEvent("juSa_npc_rewards:infoexchange", v.giveitem, v.takeitem, v.giveweapon, v.givemoney, v.takemoney, v.taskbar, v.usewebhook, v.npc_name)
                        Wait(v.taskbar)
                        Reset()
                        if Config.generalCooldown then
                            NewCooldowns()
                        else
                            npcCooldowns[i] = v.cooldown or 0
                        end
                    elseif Citizen.InvokeNative(0xC92AC953F0A982AE, noPrompt) then
                        PromptRemoveGroup(decision)
                        Core.NotifyBottomRight(Config.Language.seeUlater, 4000)
                        Wait(4000)
                        Reset()
                    end   
                elseif v.type == "sell_weapon" then
                    sleep = false
                    if not MenuTriggered then
                        TriggerServerEvent("juSa_npc_rewards:getAllWeaponsForMenu") --get all weapons in players inv
                        Wait(100)
                    elseif MenuTriggered and not WeaponChoosed then
                        if Config.Debug then
                            print("Waiting for the player to select a weapon from the menu ...")
                        end
                        Wait(100) --wait until menu gets triggered and player choosed a weapon 
                    elseif MenuTriggered and WeaponChoosed then --when player choosed a weapon in menu to sell
                        local canSell = false
                        local weaponlabel = ""
                        local weaponreward = nil
                        local weapon
                        for i, w in ipairs(v.takeweapon) do --check if NPC buys that weapon
                            if w.weaponname == selectedWeapon then
                                weapon = w
                                weaponlabel = w.label
                                weaponreward = w.givemoney
                                canSell = true
                                break
                            end
                        end
                        if not canSell then --feedback NPC does not buy that kind of weapon
                            Core.NotifyBottomRight(Config.Language.notBuyingWeapon,4000)
                            Wait(4000)
                            Reset()
                        else            
                            local itemInfo = ""
                            if weapon.giveitems then
                                for _, item in ipairs(weapon.giveitems) do
                                    itemInfo = itemInfo .. tostring(item.amount) .. "x " .. item.label .. ", "
                                end
                            else
                                if Config.Debug then
                                    print("No items available for this weapon in the config.")
                                end
                            end
                            itemInfo = string.sub(itemInfo, 1, -3)  -- removes trailing comma and space
                            local info = string.format(Config.Language.sellWeaponInfo, weapon.label, itemInfo, weapon.givemoney)
                            local label = CreateVarString(10, 'LITERAL_STRING', info)
                            PromptRemoveGroup(talktoprompt) --unload talktonpc prompt
                            PromptSetActiveGroupThisFrame(decision, label) --loads decision prompt
                            if Citizen.InvokeNative(0xC92AC953F0A982AE, yesPrompt) then
                                TriggerServerEvent("juSa_npc_rewards:infosell_weapon", v.taskbar, v.usewebhook, v.npc_name, weapon, WeaponID)
                                Wait(v.taskbar)
                                Reset()
                                if Config.generalCooldown then
                                    NewCooldowns()
                                else
                                    npcCooldowns[i] = v.cooldown or 0
                                end
                            elseif Citizen.InvokeNative(0xC92AC953F0A982AE, noPrompt) then
                                PromptRemoveGroup(decision)
                                Core.NotifyBottomRight(Config.Language.seeUlater,4000)
                                Wait(4000)
                                Reset()
                            end    
                        end
                    end        
                end
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

RegisterNetEvent("juSa_npc_rewards:openWeaponMenu")
AddEventHandler("juSa_npc_rewards:openWeaponMenu", function(weapons) --opens menu with 1 entry for every weapon in players inv
    local elements = {}
    Menu.CloseAll()
    MenuTriggered = true
    print(MenuTriggered)

    for i, weapon in ipairs(weapons) do -- load weapons and names
        table.insert(elements, {
            label = weapon.label, 
            value = weapon.id,
            model = weapon.name,
            desc = Config.Language.SN..weapon.serial_number.." \n"--..weapon.desc
        })
    end

    Menu.Open("default", GetCurrentResourceName(), "weapon_menu", {
        title = Config.Language.title,
        align = "top-left",
        elements = elements
    }, function(data, menu)
        WeaponChoosed = true
        selectedWeapon = data.current.model
        WeaponID = data.current.value
        print(WeaponID)
        menu.close() 
    end, function(data, menu) --if menu gets closed without choosing a weapon, everything gets a reset
        Reset()
        menu.close()
    end)
end)

RegisterNetEvent("juSa_npc_rewards:infosellsend")
AddEventHandler("juSa_npc_rewards:infosellsend", function( takeitem, givemoney, taskbar, usewebhook, npc_name)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed,true)
    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_BADASS"), taskbar, true, false, false, false)
    progressbar.start(Config.Language.selling_item, taskbar, nil, linear)
    Citizen.Wait(taskbar)
    TriggerServerEvent("juSa_npc_rewards:sell", takeitem, givemoney, usewebhook, npc_name)
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed,false)
end)

RegisterNetEvent("juSa_npc_rewards:infoexchangesend")
AddEventHandler("juSa_npc_rewards:infoexchangesend", function(takeitem, giveitem, giveweapon, givemoney, takemoney, taskbar, usewebhook, npc_name)
    local playerPed = PlayerPedId()
    FreezeEntityPosition(playerPed,true)
    TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_BADASS"), taskbar, true, false, false, false)
    progressbar.start(Config.Language.exchanging_item, taskbar, nil, linear)
    Citizen.Wait(taskbar)
    TriggerServerEvent("juSa_npc_rewards:exchange", giveitem, takeitem, giveweapon, givemoney, takemoney, usewebhook, npc_name)
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed,false)
end)

RegisterNetEvent("juSa_npc_rewards:info_sell_weapon_send")
AddEventHandler("juSa_npc_rewards:info_sell_weapon_send", function(taskbar, usewebhook, npc_name, weapon, WeaponID, hasSpace)
    if hasSpace then --if player has inv space
        local playerPed = PlayerPedId()
        FreezeEntityPosition(playerPed,true)
        TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_BADASS"), taskbar, true, false, false, false)
        progressbar.start(Config.Language.selling_weapon, taskbar, nil, linear)
        Citizen.Wait(taskbar)
        TriggerServerEvent("juSa_npc_rewards:sell_weapon", usewebhook, npc_name, weapon, WeaponID)
        ClearPedTasks(playerPed)
        FreezeEntityPosition(playerPed,false)
    else
        Core.NotifyBottomRight(Config.Language.invToFull,4000) --if inv to full
        Reset()
    end
end)

RegisterNetEvent("juSa_npc_rewards:jobchecked")
AddEventHandler("juSa_npc_rewards:jobchecked", function(result)
    hasjob = result
end)

function NewCooldowns() --set new cooldowns
    generalCooldown = Config.Cooldown
    for i, v in ipairs(Config.NPCs) do
        if Config.generalCooldown then -- set new cooldown for every NPC
            if v.cooldown ~= nil then
                npcCooldowns[i] = generalCooldown
            else
                npcCooldowns[i] = 0 
            end
        end
    end
end

function Reset() --resets vars
    hasjob = false
    talking = false
    MenuTriggered = false
    WeaponChoosed = false
    selectedWeapon = nil
    WeaponID = nil
end

Citizen.CreateThread(function() --handeling cooldown counting
    while true do
        Citizen.Wait(1000)
        if generalCooldown > 0 then
            generalCooldown = generalCooldown - 1
        end
        for i, cooldown in ipairs(npcCooldowns) do
            if cooldown > 0 then
                npcCooldowns[i] = cooldown - 1
            end
        end
        if talkingTime > 0 then
            talkingTime = talkingTime -1
        else
            Reset()
        end
    end
end)

---- Debug commands ----
RegisterCommand("printCd", function()
    if Config.Debug then --command if debug = true to print every cooldown
        PrintCooldowns()
    end
end, false)

RegisterCommand('resetCd', function() --set all cooldowns to 0
    if Config.Debug then
        for i, v in ipairs(Config.NPCs) do
            v.cooldown = 0
            print("NPC name:", v.npc_name, "Cooldown was set to 0")
        end
        generalCooldown = 0
    end
end, false)

function PrintCooldowns() --prints cooldowns for every NPC
    print("General Cooldown:", generalCooldown)
    for i, v in ipairs(Config.NPCs) do
        local npcName = v.npc_name or "Unknown NPC"
        local cooldown = npcCooldowns[i] or 0
        print("NPC Name:", npcName, "Cooldown:", cooldown)
    end
end