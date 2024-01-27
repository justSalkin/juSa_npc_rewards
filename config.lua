Config = {}

Config.DiscordWebHook = ""
Config.DiscordBotName= "juSa NPC Rewards"

Config.useRightNotify = false --if true use right notify, if false use notify on the left

----------------------------- NPC Settings -------------------------------------
-- NPC Types:   "give" = NPC gives player items and/or money
--              "sell" = NPC takes items and pays amount of $ back
--              "exchange" = NPC takes item and/or money and gives money and/or items back
--              "nointeraction" = just an NPC, you can't interact with them
--------------------------------------------------------------------------------

Config.NPCs = {
    --No Interaction
    { npc_name = "Valentine Saloon", blip = 0, npcmodel = "U_F_M_TljBartender_01", coords = vector3(-313.25, 805.35, 117.98), heading = -80.23, radius = 0, type = "nointeraction", scenario = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS", anim = { animDict = false, animName = "" }},

    { npc_name = "Give-NPC", -- NPC/blip name
    blip = 214435071, --set to 0 to not display a blip for this NPC
    npcmodel = "CS_CABARETMC", --npc skin, randomoutfit = true
    coords = vector3(2710.51, -1385.59, 45.43), 
    heading = 189.77, 
    radius = 4.0, --interaction radius
    scenario = false, -- set to false to use no scenario | find some here: https://github.com/femga/rdr3_discoveries/blob/master/animations/scenarios/scenario_types_with_conditional_anims.lua
    anim = { animDict = false, animName = "" }, -- set to false to not use animations | find more here: https://raw.githubusercontent.com/femga/rdr3_discoveries/master/animations/ingameanims/ingameanims_list.luas
    taskbar = 3000, --duration of the interaction
    usewebhook = true, --set true, if you want to get discord notification when interact with npc
    type = "give", -- see NPC Settings for more informations
    giveitem = {{ item = "apple", label = "apple", amount = 2 } , { item = "peach", label = "peach", amount = 1 }}, -- when interact -> gives player 2 apple and 1 peach
    givemoney = 5, -- also gives player 5$
    },

    { npc_name = "Sell-NPC", 
    blip = 214435071, 
    npcmodel = "CS_MP_TRAVELLINGSALESWOMAN", 
    coords = vector3(2681.41, -1399.55, 45.38), 
    heading = -108.46, 
    radius = 4.0,
    scenario = "WORLD_HUMAN_WRITE_NOTEBOOK",
    anim = { animDict = false, animName = "" }, 
    taskbar = 6000,
    usewebhook = true,
    type = "sell",
    takeitem = {{ item = "apple", label = "apple", amount = 2 } , { item = "peach", label = "peach", amount = 1 }}, -- takes items from player
    givemoney = 10, --gives money in exchange
    },

    { npc_name = "Exchange-NPC", 
    blip = 214435071, 
    npcmodel = "CS_MP_TRAVELLINGSALESWOMAN", 
    coords = vector3(2698.74, -1407.68, 45.65), 
    heading = -108.46, 
    radius = 4.0,
    scenario = false,
    anim = { animDict = false, animName = "" }, 
    taskbar = 3000,
    usewebhook = true,
    type = "exchange", 
    giveitem = {{ item = "peach", label = "peach", amount = 1 }},
    takeitem = {{ item = "apple", label = "apple", amount = 2 }},
    givemoney = 0, 
    takemoney = 5,
    },
}

----------------------------- TRANSLATE HERE -------------------------------------
Config.Language = {
    --Prompts
    talk = "Talk to NPC",
    press = "press ",
    noLabel = "NO",
    yesLabel = "YES",
    sellinfo = "Do you want to sell %s for %d$ ?",
    seeUlater = "Ok, see you later then.",
    exchangeinfo = "Do you want to exchange %s and %d$ against %s and %d$ ?",
    --progressbar
    getting_item = "you'r getting items ... ",
    selling_item = "about to sell something ... ",
    exchanging_item = "exchanging ...",
    --notify
    notenougitems = "You do not have enough items!",
    got = "You got: ",
    title_got = "You got: ",
    sold = "You sold: ",
    title_sold = "You sold: ",
    exchanged = "You have exchanged: ",
    title_exchanged = "You have exchanged: ",
    payed = "You payed: ",
    title_payed = "You payed: ",
    --discord
    discord_title_give = "NPC GIVE",
    discord_title_sell = "NPC SELL",
    discord_title_exchange = "NPC EXCHANGE"
}
------------------- PROMPT -----------------
Config.keys = {
    G = 0x760A9C6F, -- talk/interact
    UP = 0x6319DB71, --yes
    DOWN = 0x05CA7C52 , --no
}
