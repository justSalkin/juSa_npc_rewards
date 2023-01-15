local prompts = GetRandomIntInRange(0, 0xffffff)

local VorpCore = {}
local VORPInv = {}

TriggerEvent("getCore",function(core)
    VorpCore = core
end)

RegisterNetEvent("vorp:SelectedCharacter") -- NPC loads after selecting character
AddEventHandler("vorp:SelectedCharacter", function(charid)
StartNPCs()
end)

function StartNPCs()
    for i, v in ipairs(Config.NPCs) do
        local x, y, z = table.unpack(v.coords)
        -- Loading Model
        local hashModel = GetHashKey(v.npcmodel)
        if IsModelValid(hashModel) then
            RequestModel(hashModel)
            while not HasModelLoaded(hashModel) do
                Wait(100)
            end
        else
            print(v.npcmodel .. " is not valid")
        end
        -- Spawn NPC Ped
        local npc = CreatePed(hashModel, x, y, z, v.heading, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(1000)
        FreezeEntityPosition(npc, true) -- NPC can't escape
        SetBlockingOfNonTemporaryEvents(npc, true) -- NPC can't be scared
        --create blip
        if v.blip ~= 0 then
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
            SetBlipSprite(blip, v.blip, true)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.npc_name)
        end
    end
end

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    local str = Config.Language.press
    talktonpc = PromptRegisterBegin()
    PromptSetControlAction(talktonpc, Config.keys["G"])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(talktonpc, str)
    PromptSetEnabled(talktonpc, 1)
    PromptSetVisible(talktonpc, 1)
    PromptSetStandardMode(talktonpc, 1)
    PromptSetHoldMode(talktonpc, 1)
    PromptSetGroup(talktonpc, prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, talktonpc, true)
    PromptRegisterEnd(talktonpc)
end)

Citizen.CreateThread(function()
    while true do
        local sleep = true
        local _source = source
        for i, v in ipairs(Config.NPCs) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            if Vdist(playerCoords, v.coords) <= v.radius then -- Checking distance between player and npc
                if v.type ~= "nointeraction" then
                    sleep = false
                    local label = CreateVarString(10, 'LITERAL_STRING', Config.Language.talk)
                    PromptSetActiveGroupThisFrame(prompts, label)
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, talktonpc) then
                        local playerPed = PlayerPedId()
                        FreezeEntityPosition(playerPed,true)
                        -- give items
                        if v.type == "give" then
                            TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), Config.taskbar, true, false, false, false) --Taskbar-Animation (change the text in "" if u want to have another animation instead)
                            exports['progressBars']:startUI(Config.taskbar, Config.Language.getting_item)
                            Citizen.Wait(Config.taskbar)
                            TriggerServerEvent("juSa_npc_rewards:give", v.giveitem) -- give item
                        -- sell items
                        elseif v.type == "sell" then
                            TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), Config.taskbar, true, false, false, false)
                            exports['progressBars']:startUI(Config.taskbar, Config.Language.selling_item)
                            Citizen.Wait(Config.taskbar)
                            TriggerServerEvent("juSa_npc_rewards:sell", v.takeitem, v.givemoney)
                            --exchange items
                        elseif v.type == "exchange" then
                            TaskStartScenarioInPlace(playerPed, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), Config.taskbar, true, false, false, false)
                            exports['progressBars']:startUI(Config.taskbar, Config.Language.exchanging_item)
                            Citizen.Wait(Config.taskbar)
                            TriggerServerEvent("juSa_npc_rewards:exchange", v.giveitem, v.takeitem, v.givemoney, v.takemoney)
                        end
                        ClearPedTasks(playerPed)
                        FreezeEntityPosition(playerPed,false)
                        Wait(500)
                        Citizen.Wait(1000)
                    end
                end
            end
        end
        if sleep then
            Citizen.Wait(500)
        end
        Citizen.Wait(1)
    end
end)