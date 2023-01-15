VorpCore = {}
local VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
local VORP_API = exports.vorp_core:vorpAPI()
local webhook = ""

TriggerEvent("getCore",function(core)
    VorpCore = core
end)

RegisterServerEvent("juSa_npc_rewards:give")
AddEventHandler("juSa_npc_rewards:give", function(giveitem)
    local _source = source
    for k,v in ipairs(giveitem) do
        VORPInv.addItem(_source, v.item, v.amount)
    end
end)

RegisterServerEvent("juSa_npc_rewards:sell")
AddEventHandler("juSa_npc_rewards:sell", function(takeitem, givemoney)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local getmoney = true
    -- check for enough items
    for i,v in ipairs(takeitem) do
        count = VORPInv.getItemCount(_source, v.item)
        if count < v.amount then
            getmoney = false
            TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
        end
    end
    if getmoney == true then
        for k,v in ipairs(takeitem) do
            VORPInv.subItem(_source, v.item, v.amount)
        end
        Character.addCurrency(0, givemoney)
        getmoney = false
    end
end)

RegisterServerEvent("juSa_npc_rewards:exchange")
AddEventHandler("juSa_npc_rewards:exchange", function(giveitem, takeitem, givemoney, takemoney)
    local _source = source
    local Character = VorpCore.getUser(_source).getUsedCharacter
    local check = true
    -- check for enough items
    for i,v in ipairs(takeitem) do
        count = VORPInv.getItemCount(_source, v.item)
        if count < v.amount then
            check = false
            TriggerClientEvent("vorp:TipRight", _source, Config.Language.notenougitems, 3000)
        end
    end
    if check == true then
        for k,v in pairs(giveitem) do
            VORPInv.addItem(_source, v.item, v.amount)
        end
        for k,v in pairs(takeitem) do
            VORPInv.subItem(_source, v.item, v.amount)
        end
        Character.addCurrency(0, givemoney)
        Character.removeCurrency(0, takemoney)
        check = false
    end
end)