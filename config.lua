Config = {}

-- LAST EDIT by just_Salkin 15.01.2023 | WHITE-SANDS-RP german RP server

Config.taskbar = 3000 --Interaction takes 3sec

----------------------------- NPC Settings -------------------------------------

--NPC Types:    "give" = NPC gives Player Items
--              "sell" = NPC takes Items and pays amount of $ back
--              "exchange" = NPC takes Item or money and gives money or another item back
--              "nointeraction" = just an NPC, you can't interact with them
--------------------------------------------------------------------------------

Config.NPCs = {
    --No Interaction
    { npc_name = "Valentine Saloon", blip = 0, npcmodel = "U_M_M_RhdBartender_01", coords = vector3(-313.25, 805.35, 117.98), heading = -80.23, radius = 0, type = "nointeraction"},

    { npc_name = "Give-NPC", -- NPC/blip name
    blip = 214435071, --set to 0 to not display a blip for this NPC
    npcmodel = "CS_CABARETMC", 
    coords = vector3(2710.51, -1385.59, 45.43), 
    heading = 189.77, 
    radius = 4.0, --interaction radius
    type = "give", -- see NPC Settings for more informations
    giveitem = {{ item = "apple", amount = 2 } , { item = "consumable_lemon", amount = 1 }}, -- when interact -> gives player 2 Apple and 1 Lemon
    takeitem = {},
    givemoney = 0, 
    takemoney = 0
    },

    { npc_name = "Sell-NPC", 
    blip = 214435071, 
    npcmodel = "CS_MP_TRAVELLINGSALESWOMAN", 
    coords = vector3(2681.41, -1399.55, 45.38), 
    heading = -108.46, 
    radius = 4.0, 
    type = "sell", 
    giveitem = {}, 
    takeitem = {{ item = "apple", amount = 2 } , { item = "consumable_lemon", amount = 1 }}, -- takes 2 Apple and 1 Lemon from players inv.
    givemoney = 10, -- gives 10$ in exchange for the Items
    takemoney = 0
    },

    { npc_name = "Exchange-NPC", 
    blip = 214435071, 
    npcmodel = "CS_MP_TRAVELLINGSALESWOMAN", 
    coords = vector3(2698.74, -1407.68, 45.65), 
    heading = -108.46, 
    radius = 4.0, 
    type = "exchange", 
    giveitem = {{ item = "consumable_lemon", amount = 1 }}, -- gives player 1 Lemon for 2 Apples
    takeitem = {{ item = "apple", amount = 2 }},
    givemoney = 0, 
    takemoney = 5
    },
}

----------------------------- TRANSLATE HERE -------------------------------------
Config.Language = {
    talk = "talk to npc",
    press = "press ",
    getting_item = "you're receiving items ... ",
    selling_item = "sale in progress ... ",
    exchanging_item = "you are exchanging items ...",
    notenougitems = "You don't have enough items!"
}
------------------- PROMPT -----------------
Config.keys = {
    G = 0x760A9C6F, -- talk/interact
}