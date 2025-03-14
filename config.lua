Config = {}

Config.Debug = true --enables input commands and some consol-prints | for details check out git or discord

Config.DiscordWebhook = ""
Config.DiscordBotName = "juSa NPC Rewards"
Config.DiscordAvatar = "https://i.postimg.cc/TYm9DdHT/jusa-scripts.png"

Config.useRightNotify = false --if true use right notify, if false use notify on the left
Config.generalCooldown = false --turn on/off cooldown for every NPC | after one interaction with any NPC the player gets new cooldown for EVERY NPC
Config.Cooldown = 0 --in sec

Config.talkingTime = 7 --sec how long you can interact with one NPC until he is not longer responding to you and you have to "talk" to the NPC again
----------------------------- NPC Settings -------------------------------------

--NPC Types:    "give" = NPC gives player items / weapons / money
--              "sell" = NPC takes items and pays amount of $ back
--              "sell_weapon" = NPC takes weapon and pays amount of $ back and/or gives you items in return
--              "exchange" = NPC takes items/money and gives items/weapons/money in return
--              "nointeraction" = just an NPC, you can't interact with them
--------------------------------------------------------------------------------

Config.NPCs = {
    --No Interaction | Valentine
    { npc_name = "Valentine Saloon", blip = 0, npcmodel = "U_F_M_TljBartender_01", coords = vector3(-313.25, 805.35, 117.98), heading = -80.23, radius = 0, type = "nointeraction", scenario = "WORLD_HUMAN_BARTENDER_CLEAN_GLASS", anim = { animDict = false, animName = "" }},
    --Interactiv
    { npc_name = "Give-NPC", -- NPC/blip name
    blip = 214435071, --set to 0 to not display a blip for this NPC
    npcmodel = "CS_CABARETMC", --npc skin, randomoutfit = true
    coords = vector3(2710.51, -1385.59, 45.43), 
    heading = 189.77, 
    radius = 4.0, --interaction radius
    scenario = false, -- set to false to use no scenario | find some here: https://github.com/femga/rdr3_discoveries/blob/master/animations/scenarios/scenario_types_with_conditional_anims.lua
    anim = { animDict = false, animName = '' }, -- set to false to not use animations | find more here: https://raw.githubusercontent.com/femga/rdr3_discoveries/master/animations/ingameanims/ingameanims_list.lua
    cooldown = 20, --set individual cooldown | in sec
    joblocked = {{name = "SheriffV", grade = 2}, {name = "DoctorV", grade = 3}}, --set nil if you want every job to use this NPC
    taskbar = 3000, --duration of the interaction
    usewebhook = true, --set true, if you want to get discord notification when interact with npc
    type = "give", -- see NPC Settings for more informations
    giveitem = {{ item = "apple", label = "apple", amount = 2 } , { item = "peach", label = "peach", amount = 1 }}, -- when interact -> gives player 2 apple and 1 peach
    giveweapon = {{weaponname = "WEAPON_MELEE_KNIFE", label = "knife"}, {weaponname = "WEAPON_REVOLVER_CATTLEMAN", label = "Cattleman Revolver"}},
    givemoney = 5, -- also gives player 5$
    },

    { npc_name = "Sell-NPC", 
    blip = 214435071, 
    npcmodel = "CS_MP_TRAVELLINGSALESWOMAN", 
    coords = vector3(2681.41, -1399.55, 45.38), 
    heading = -108.46, 
    radius = 4.0, 
    scenario = false, 
    anim = { animDict = false, animName = '' }, 
    cooldown = 20, 
    joblocked = nil,
    taskbar = 3000,
    usewebhook = true,
    type = "sell",
    takeitem = {{ item = "apple", label = "apple", amount = 2 } , { item = "peach", label = "peach", amount = 1 }}, -- takes items from player
    givemoney = 10, --gives money in exchange
    },

    { npc_name = "Exchange-NPC", 
    blip = 214435071, 
    npcmodel = "mp_u_m_m_nat_farmer_04", 
    coords = vector3(2698.74, -1407.68, 45.65), 
    heading = -108.46, 
    radius = 4.0, 
    scenario = false, 
    anim = { animDict = false, animName = '' }, 
    cooldown = 20, 
    joblocked = nil, 
    taskbar = 3000,
    usewebhook = true,
    type = "exchange", 
    giveitem = {{ item = "peach", label = "peach", amount = 1 }},
    takeitem = {{ item = "apple", label = "apple", amount = 2 }},
    giveweapon = nil,
    givemoney = 0, 
    takemoney = 5,
    },

    { npc_name = "Sell_weapon-NPC",
    blip = 214435071,
    npcmodel = "mp_u_m_m_lbt_hostagemarshal_01", 
    coords = vector3(2695.74, -1403.68, 45.65), 
    heading = -61.44, 
    radius = 2.5,
    scenario = false,
    anim = { animDict = false, animName = '' }, 
    cooldown = 30,
    joblocked = {{name = "gunsmith", grade = 3},},
    taskbar = 3000,
    usewebhook = true,
    type = "sell_weapon",
    takeweapon = {  {weaponname = "WEAPON_REPEATER_HENRY", label = "Henry Repeater", givemoney = 100, giveitems = {{name = "apple", label = "apple", amount = 1}}}, 
                    {weaponname = "WEAPON_REVOLVER_NAVY", label = "Navy Revolver", givemoney = 280, giveitems = {}},
                    {weaponname = "WEAPON_SNIPERRIFLE_ROLLINGBLOCK", label = "Rolling-Block Sniper", givemoney = 450, giveitems = {{name = "stone", label = "stone", amount = 3}, {name = "apple", label = "apple", amount = 1}}}
                }
    },
}

----------------------------- TRANSLATE HERE -------------------------------------
Config.Language = {
    --prompts
    talk = "Talk to NPC",
    press = "press ",
    noLabel = "NO",
    yesLabel = "YES",
    onCooldown = "I'm busy. Come back later ...",
    wrongJob = "I think you've come to the wrong place ...",
    sellinfo = "Do you want to sell %s for %d$ ?",
    sellWeaponInfo = "Do you want to sell %s for %s and %d $?",
    exchangeinfo = "Do you want to exchange %s and %d$ against %s and %d$ ?",
    seeUlater = "Ok, see you later then.",
    notBuyingWeapon = "I don't buy that kind of gun. I'm sorry.",
    invToFull = "I don't think you have enough space in your bag.",
    --progressbar
    getting_item = "you'r getting items ... ",
    selling_item = "about to sell something ... ",
    exchanging_item = "exchanging ...",
    selling_weapon = "You deal with the weapon ...",
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
    lowgrade = "Your job grade is too low.",
    wrongjob = "You don't have the right job for this.",
    noitemneeded = "no item   ",
    noitemrec = "no item   ",
    noweapons = "Looks like you have no weapons to trade with.",
    --discord
    webhook_got = "Got ",
    webhook_from = " from ",
    webhook_sold = "Sold ",
    webhook_to = " to ",
    webhook_for = " for ",
    webhook_exchanged = "Exchanged: ",
    webhook_soldweapon = "Sold a ",
    webhook_at = " an ",
    webhook_with = " with ",
    --menu
    title = "Weapons menu",
    SN = "Serial number: "
}
------------------- PROMPT -----------------
Config.keys = {
    G = 0x760A9C6F, -- talk/interact
    UP = 0x6319DB71, --yes
    DOWN = 0x05CA7C52 , --no
}