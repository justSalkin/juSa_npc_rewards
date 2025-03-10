local Core = exports.vorp_core:GetCore()
local VORPInv = exports.vorp_inventory:vorp_inventoryApi()
-- find more notify blips here: https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/blips
local giveitem = {}
local takeitem = {}

RegisterServerEvent("juSa_npc_rewards:jobcheck")
AddEventHandler("juSa_npc_rewards:jobcheck", function(jobs)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local hasJob = false
    local hasRequiredGrade = false
    local result = nil
    for i, v in ipairs(jobs) do --check list of jobs
        if v.name == Character.job then --checks for job
            hasJob = true
            if v.grade <= Character.jobGrade then
                hasRequiredGrade = true
                break  --stops when player has a correct job and grade 
            end
        end
    end
    if hasJob and hasRequiredGrade then
        result = true
        TriggerClientEvent("juSa_npc_rewards:jobchecked", _source, result)
    elseif hasJob and not hasRequiredGrade then
        result = false
        TriggerClientEvent("vorp:TipRight", _source, Config.Language.lowgrade, 5000)
        TriggerClientEvent("juSa_npc_rewards:jobchecked", _source, result)
    else
        result = false
        TriggerClientEvent("vorp:TipRight", _source, Config.Language.wrongjob, 5000)
        TriggerClientEvent("juSa_npc_rewards:jobchecked", _source, result)
    end
end)

RegisterServerEvent("juSa_npc_rewards:getAllWeaponsForMenu")
AddEventHandler("juSa_npc_rewards:getAllWeaponsForMenu", function() --get all weapons -> client
    local _source = source 
    exports.vorp_inventory:getUserInventoryWeapons(_source, function(weaponsData)
        if weaponsData and #weaponsData > 0 then
            TriggerClientEvent("juSa_npc_rewards:openWeaponMenu", _source, weaponsData)
        else
            TriggerClientEvent("juSa_npc_rewards:notify", _source, Config.Language.noweapons)
        end
    end)
end)

RegisterServerEvent("juSa_npc_rewards:give")
AddEventHandler("juSa_npc_rewards:give", function(giveitem, givemoney, giveweapon, usewebhook, npc_name)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local firstname = Character.firstname
    local lastname = Character.lastname
    local rewardText = ""
    for k,v in ipairs(giveitem) do
        VORPInv.addItem(_source, v.item, v.amount)
        rewardText = rewardText .. v.amount .. "x " .. v.label .. ", "
        if Config.Debug then
            print(v.amount.."x "..v.label.." was given to "..firstname.." "..lastname)
        end
    end
    if not giveweapon == nil then
        for k,v in ipairs(giveweapon) do
            exports.vorp_inventory:canCarryWeapons(_source, #giveweapon, function(canCarry)
                if canCarry then
                    if v.weaponname then
                        exports.vorp_inventory:createWeapon(_source, v.weaponname, {["ammo"] = 0}, {})
                        rewardText = rewardText .. v.label .. ", "
                        if Config.Debug then
                            print(v.label.." was given to "..firstname.." "..lastname)
                        end
                    else
                        print("Weapon name is nil for entry "..k)
                    end
                else
                    print("Cannot carry more weapons")
                    Core.NotifyRightTip(_source, "Can't carry more weapons.", 4000)
                end
            end, v.weaponname)
        end
    end
    Character.addCurrency(0, givemoney)
    rewardText = rewardText .. givemoney .. " $"
    if Config.Debug then
        print(givemoney.."$ was given to "..firstname.." "..lastname)
    end
    if Config.useRightNotify then --notify
        for k,v in ipairs(giveitem) do
            Core.NotifyRightTip(_source, Config.Language.got..v.amount.."x "..v.label,4000)
        end
        for k,v in ipairs(giveweapon) do
            Core.NotifyRightTip(_source, Config.Language.got.."1x "..v.label,4000)
        end
        Core.NotifyRightTip(_source, Config.Language.got..givemoney.." $",4000)
    else
        for k,v in ipairs(giveitem) do
            Core.NotifyLeft(_source, Config.Language.title_got, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_GREEN")
        end
        for k,v in ipairs(giveweapon) do
            Core.NotifyLeft(_source, Config.Language.title_got, "1x " .. v.label, "BLIPS", "blip_weapon", 4000, "COLOR_GREEN")
        end
        Core.NotifyLeft(_source, Config.Language.title_got, givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
    end
    if usewebhook then
        Core.AddWebhook(firstname.." "..lastname, Config.DiscordWebhook, Config.Language.webhook_got .. rewardText .. Config.Language.webhook_from .. npc_name, 1, Config.DiscordBotName, "", "", Config.DiscordAvatar)
    end
end)

RegisterServerEvent("juSa_npc_rewards:infosell")
AddEventHandler("juSa_npc_rewards:infosell", function(takeitem, givemoney, taskbar, usewebhook, npc_name)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local checked = true
    for i,v in ipairs(takeitem) do -- check for enough items
        count = VORPInv.getItemCount(_source, v.item)
        if count < v.amount then
            TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
            checked = false
        end
    end
    if checked == true then
        TriggerClientEvent("juSa_npc_rewards:infosellsend", _source, takeitem, givemoney, taskbar, usewebhook, npc_name)
    end
end)

RegisterServerEvent("juSa_npc_rewards:sell")
AddEventHandler("juSa_npc_rewards:sell", function(takeitem, givemoney, usewebhook, npc_name)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local firstname = Character.firstname
    local lastname = Character.lastname
    local rewardText = ""
    for k,v in ipairs(takeitem) do
        exports.vorp_inventory:subItem(_source, v.item, v.amount)
        rewardText = rewardText .. v.amount .. "x " .. v.label .. ", "
    end
    rewardText = rewardText .. Config.Language.webhook_for
    Character.addCurrency(0, givemoney)
    rewardText = rewardText .. givemoney .. " $"
    if Config.useRightNotify then --notify
        for k,v in ipairs(takeitem) do
            Core.NotifyRightTip(_source, Config.Language.sold..v.amount.."x "..v.label,4000)
        end
        Core.NotifyRightTip(_source, Config.Language.got..addCurrency.amount.."$ ",4000)
    else
        for k,v in ipairs(takeitem) do
            Core.NotifyLeft(_source, Config.Language.title_sold, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_RED")
        end
        Core.NotifyLeft(_source, Config.Language.title_got, givemoney .. "$ ","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
    end
    if usewebhook then
        Core.AddWebhook(firstname.." "..lastname, Config.DiscordWebhook, Config.Language.webhook_sold .. rewardText .. Config.Language.webhook_to .. npc_name, 1, Config.DiscordBotName, "", "", Config.DiscordAvatar)
    end
end)

RegisterServerEvent("juSa_npc_rewards:infoexchange")
AddEventHandler("juSa_npc_rewards:infoexchange", function(giveitem, takeitem, giveweapon, givemoney, takemoney, taskbar, usewebhook, npc_name)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local checked = true
    if takeitem and #takeitem > 0 then
        for i,v in ipairs(takeitem) do -- check for enough items
            count = VORPInv.getItemCount(_source, v.item)
            if count < v.amount then
                checked = false
                TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
            end
        end
    end
    if checked == true then
        TriggerClientEvent("juSa_npc_rewards:infoexchangesend", _source, takeitem, giveitem, giveweapon, givemoney, takemoney, taskbar, usewebhook, npc_name)
    end
end)

RegisterServerEvent("juSa_npc_rewards:exchange")
AddEventHandler("juSa_npc_rewards:exchange", function(giveitem, takeitem, giveweapon, givemoney, takemoney, usewebhook, npc_name)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local firstname = Character.firstname
    local lastname = Character.lastname
    local rewardText = ""
    -- order for webhook first give
    if giveitem and #giveitem > 0 then
        for k,v in pairs(giveitem) do
            VORPInv.addItem(_source, v.item, v.amount)
            rewardText = rewardText .. v.amount .. "x " .. v.label .. ", "
        end
    end
    if not giveweapon == nil then
        for k,v in ipairs(giveweapon) do
            exports.vorp_inventory:canCarryWeapons(_source, #giveweapon, function(canCarry)
                if canCarry then
                    if v.weaponname then
                        exports.vorp_inventory:createWeapon(_source, v.weaponname, {["ammo"] = 0}, {})
                        rewardText = rewardText .. "1x " .. v.label .. ", "
                        if Config.Debug then
                            print(v.label.." was given to "..firstname.." "..lastname)
                        end
                    else
                        print("Weapon name is nil for entry "..k)
                    end
                else
                    print("Cannot carry more weapons")
                    Core.NotifyRightTip(_source, "Can't carry more weapons.", 4000)
                end
            end, v.weaponname)
        end
    end
    Character.addCurrency(0, givemoney)
    rewardText = rewardText .. givemoney .. " $ "
    rewardText = rewardText .. Config.Language.webhook_for
    -- then take items -> rewardText
    if takeitem and #takeitem > 0 then
        for k,v in pairs(takeitem) do
            VORPInv.subItem(_source, v.item, v.amount)
            rewardText = rewardText .. v.amount .. "x " .. v.label .. ", "
        end
    end
    Character.removeCurrency(0, takemoney)
    rewardText = rewardText .. takemoney .. " $ "
    if Config.useRightNotify then --notify
        if giveitem and #giveitem > 0 then
            for k,v in ipairs(giveitem) do
                Core.NotifyRightTip(_source, Config.Language.got..v.amount.."x "..v.label,4000)
            end
        end
        if takeitem and #takeitem > 0 then
            for k,v in ipairs(takeitem) do
                Core.NotifyRightTip(_source, Config.Language.exchanged..v.amount.."x "..v.label,4000)
            end
        end
        if giveweapon and #giveweapon > 0 then
            for k,v in ipairs(giveweapon) do
                Core.NotifyRightTip(_source, Config.Language.got.."1x "..v.label,4000)
            end
        end
        Core.NotifyRightTip(_source, Config.Language.got..givemoney.." $",4000)
        Core.NotifyRightTip(_source, Config.Language.payed..takemoney.." $",4000)
    else
        if giveitem and #giveitem > 0 then
            for k,v in ipairs(giveitem) do
                Core.NotifyLeft(_source, Config.Language.title_got, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_GREEN")
            end
        end
        if takeitem and #takeitem > 0 then
            for k,v in ipairs(takeitem) do
                Core.NotifyLeft(_source, Config.Language.title_exchanged, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_RED")
            end
        end
        if giveweapon and #giveweapon > 0 then
            for k,v in ipairs(giveweapon) do
                Core.NotifyLeft(_source, Config.Language.title_got, "1x " .. v.label, "BLIPS", "blip_weapon", 4000, "COLOR_GREEN")
            end
        end
        Core.NotifyLeft(_source, Config.Language.title_got, givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
        Core.NotifyLeft(_source, Config.Language.title_payed, takemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_RED")
    end
    if usewebhook then
        Core.AddWebhook(firstname.." "..lastname, Config.DiscordWebhook, Config.Language.webhook_exchanged .. rewardText .. Config.Language.webhook_with .. npc_name, 1, Config.DiscordBotName, "", "", Config.DiscordAvatar)
    end
end)

RegisterServerEvent("juSa_npc_rewards:infosell_weapon")
AddEventHandler("juSa_npc_rewards:infosell_weapon", function(taskbar, usewebhook, npc_name, weapon, WeaponID)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter

    local hasSpace = true
    local checkedItems = 0
    local totalItems = #weapon.giveitems
    
    for i, item in ipairs(weapon.giveitems) do
        exports.vorp_inventory:canCarryItem(_source, item.name, item.amount, function(canCarry)
            if Config.Debug then
                print("checked for: ", item.name)
                print("canCarry: ", canCarry)
            end
            if not canCarry then
                hasSpace = false
            end
            checkedItems = checkedItems + 1
            if checkedItems == totalItems then --to make sure that everything has been checked and not accidentally handed over as "nil"
                TriggerClientEvent("juSa_npc_rewards:info_sell_weapon_send", _source, taskbar, usewebhook, npc_name, weapon, WeaponID, hasSpace)
            end
        end)
    end
end)

RegisterServerEvent("juSa_npc_rewards:sell_weapon")
AddEventHandler("juSa_npc_rewards:sell_weapon", function(usewebhook, npc_name, weapon, WeaponID)
    local _source = source
    local Character = Core.getUser(_source).getUsedCharacter
    local firstname = Character.firstname
    local lastname = Character.lastname
    local rewardText = ""

    exports.vorp_inventory:subWeapon(_source, WeaponID) --sub weapon

    if weapon.giveitems and #weapon.giveitems > 0 then --give items
        for k,v in pairs(weapon.giveitems) do
            VORPInv.addItem(_source, v.name, v.amount)
            rewardText = rewardText .. v.amount .. "x " .. v.label .. ", "
        end
    end

    Character.addCurrency(0, weapon.givemoney) --give money
    rewardText = rewardText .. weapon.givemoney .. " $ "

    if Config.useRightNotify then --notify
        Core.NotifyRightTip(_source, Config.Language.title_soldweapon.."1x "..weapon.label,4000)
        Core.NotifyRightTip(_source, Config.Language.got.. weapon.givemoney.." $",4000)
        if weapon.giveitems and #weapon.giveitems > 0 then
            for k,v in ipairs(weapon.giveitems) do
                Core.NotifyRightTip(_source, Config.Language.got..v.amount.."x "..v.label,4000)
            end
        end
    else
        Core.NotifyLeft(_source, Config.Language.title_soldweapon, "1x " .. weapon.label, "BLIPS", "blip_weapon", 4000, "COLOR_RED")
        Core.NotifyLeft(_source, Config.Language.title_got, weapon.givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
        if weapon.giveitems and #weapon.giveitems > 0 then
            for k,v in ipairs(weapon.giveitems) do
                Core.NotifyLeft(_source, Config.Language.title_got, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_GREEN")
            end
        end
    end
    if usewebhook then
        Core.AddWebhook(firstname.." "..lastname, Config.DiscordWebhook, Config.Language.webhook_soldweapon.. weapon.label .. Config.Language.webhook_for.. rewardText .. Config.Language.webhook_at .. npc_name, 1, Config.DiscordBotName, "", "", Config.DiscordAvatar)
    end
end)