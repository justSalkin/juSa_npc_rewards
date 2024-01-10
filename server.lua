local VORPcore = exports.vorp_core:GetCore()
local VORPInv = exports.vorp_inventory:vorp_inventoryApi()

local giveitem = {}
local takeitem = {}

TriggerEvent("getCore",function(core)
    VORPcore = core
end)

RegisterServerEvent("juSa_npc_rewards:give")
AddEventHandler("juSa_npc_rewards:give", function(giveitem, givemoney)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    for k,v in ipairs(giveitem) do
        VORPInv.addItem(_source, v.item, v.amount)
    end
    Character.addCurrency(0, givemoney)
    if Config.useRightNotify then --notify
        for k,v in ipairs(giveitem) do
            VORPcore.NotifyRightTip(_source, Config.Language.got..v.amount.."x "..v.label,4000)
        end
        VORPcore.NotifyRightTip(_source, Config.Language.got..givemoney.." $",4000)
    else
        for k,v in ipairs(giveitem) do
            VORPcore.NotifyLeft(_source, Config.Language.title_got, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_GREEN")
        end
        VORPcore.NotifyLeft(_source, Config.Language.title_got, givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
    end
end)

RegisterServerEvent("juSa_npc_rewards:infosell")
AddEventHandler("juSa_npc_rewards:infosell", function(takeitem, givemoney, taskbar, usewebhook)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local checked = true
    for i,v in ipairs(takeitem) do -- check for enough items
        count = VORPInv.getItemCount(_source, v.item)
        if count < v.amount then
            TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
            checked = false
        end
    end
    if checked == true then
        TriggerClientEvent("juSa_npc_rewards:infosellsend", _source, takeitem, givemoney, taskbar, usewebhook)
    end
end)

RegisterServerEvent("juSa_npc_rewards:sell")
AddEventHandler("juSa_npc_rewards:sell", function(takeitem, givemoney)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    for k,v in ipairs(takeitem) do
        exports.vorp_inventory:subItem(_source, v.item, v.amount)
    end
    Character.addCurrency(0, givemoney)
    if Config.useRightNotify then --notify
        for k,v in ipairs(takeitem) do
            VORPcore.NotifyRightTip(_source, Config.Language.sold..v.amount.."x "..v.label,4000)
        end
        VORPcore.NotifyRightTip(_source, Config.Language.got..givemoney.." $",4000)
    else
        for k,v in ipairs(takeitem) do
            VORPcore.NotifyLeft(_source, Config.Language.title_sold, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_RED")
        end
        VORPcore.NotifyLeft(_source, Config.Language.title_got, givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
    end
end)

RegisterServerEvent("juSa_npc_rewards:infoexchange")
AddEventHandler("juSa_npc_rewards:infoexchange", function(giveitem, takeitem, givemoney, takemoney, taskbar, usewebhook)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local checked = true
    for i,v in ipairs(takeitem) do -- check for enough items
        count = VORPInv.getItemCount(_source, v.item)
        if count < v.amount then
            checked = false
            TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
        end
    end
    if checked == true then
        TriggerClientEvent("juSa_npc_rewards:infoexchangesend", _source, takeitem, giveitem, givemoney, takemoney, taskbar, usewebhook)
    end
end)

RegisterServerEvent("juSa_npc_rewards:exchange")
AddEventHandler("juSa_npc_rewards:exchange", function(giveitem, takeitem, givemoney, takemoney)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    for k,v in pairs(giveitem) do
        VORPInv.addItem(_source, v.item, v.amount)
    end
    for k,v in pairs(takeitem) do
        VORPInv.subItem(_source, v.item, v.amount)
    end
    Character.addCurrency(0, givemoney)
    Character.removeCurrency(0, takemoney)
    if Config.useRightNotify then --notify
        for k,v in ipairs(giveitem) do
            VORPcore.NotifyRightTip(_source, Config.Language.got..v.amount.."x "..v.label,4000)
        end
        for k,v in ipairs(takeitem) do
            VORPcore.NotifyRightTip(_source, Config.Language.exchanged..v.amount.."x "..v.label,4000)
        end
        VORPcore.NotifyRightTip(_source, Config.Language.got..givemoney.." $",4000)
        VORPcore.NotifyRightTip(_source, Config.Language.payed..takemoney.." $",4000)
    else
        for k,v in ipairs(giveitem) do
            VORPcore.NotifyLeft(_source, Config.Language.title_got, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_GREEN")
        end
        for k,v in ipairs(takeitem) do
            VORPcore.NotifyLeft(_source, Config.Language.title_exchanged, v.amount .. "x " .. v.label, "BLIPS", "blip_chest", 4000, "COLOR_RED")
        end
        VORPcore.NotifyLeft(_source, Config.Language.title_got, givemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_GREEN")
        VORPcore.NotifyLeft(_source, Config.Language.title_payed, takemoney .. " $","BLIPS", "blip_cash_bag", 4000, "COLOR_RED")
    end
end)

RegisterServerEvent('juSa_npc_rewards:discord')
AddEventHandler("juSa_npc_rewards:discord", function(type, giveitem, takemoney, givemoney, takeitem)
    local _source = source
    local User = VORPcore.getUser(_source)
    local Character = User.getUsedCharacter
    local CharName
    if Character ~= nil then
        if Character.lastname ~= nil then
            CharName = Character.firstname .. ' ' .. Character.lastname
        else
            CharName = Character.firstname
        end
    end

    local DiscordWebhook = Config.DiscordWebHook
    local Content = {
        username = Config.DiscordBotName,
    }
    if type == "give" then
        local itemsDescription = ""
        for _, item in ipairs(giveitem) do
            itemsDescription = itemsDescription .. tostring(giveitem[1].amount) .. "x " .. giveitem[1].item .. ", "
        end
        Content.embeds = {{
            title = Config.Language.discord_title_give,
            description = CharName .. " got " .. string.sub(itemsDescription, 1, -3) .. " and " .. tostring(givemoney or 0) .. " $",
            color = 65280 -- embed color green
        }}
    elseif type == "sell" then
        local itemsDescription = ""
        for _, item in ipairs(takeitem) do
            itemsDescription = itemsDescription .. tostring(item.amount) .. "x " .. item.item .. ", "
        end
        Content.embeds = {{
            title = Config.Language.discord_title_sell,
            description = CharName .. " sold " .. string.sub(itemsDescription, 1, -3) .. " for " .. tostring(givemoney or 0) .. " $",
            color = 16711680 -- embed color red
        }}
    elseif type == "exchange" then
        local takeItemsDescription = ""
        for _, item in ipairs(takeitem) do
            takeItemsDescription = takeItemsDescription .. tostring(item.amount) .. "x " .. item.item .. ", "
        end
        local giveItemsDescription = ""
        for _, item in ipairs(giveitem) do
            giveItemsDescription = giveItemsDescription .. tostring(item.amount) .. "x " .. item.item .. ", "
        end
        Content.embeds = {{
            title = Config.Language.discord_title_exchange,
            description = CharName .. " exchanged " .. string.sub(takeItemsDescription, 1, -3) .. " and " .. tostring(takemoney or 0) .. " for " .. string.sub(giveItemsDescription, 1, -3) .. " and " .. tostring(givemoney or 0) .. " $",
            color = 255 -- embed color blue
        }}
    end

    PerformHttpRequest(DiscordWebhook, function(err, text, headers)
        if err == 200 then
            print("message send: " .. text)
        elseif err == 204 then
            --send without return
        else
            print("error trying to send message: " .. err)
        end
    end, "POST", json.encode(Content), {["Content-Type"] = "application/json"})
end)