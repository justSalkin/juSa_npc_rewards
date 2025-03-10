# juSa_npc_rewards (v.1.6)
A script that allows you to create NPCs and assign various functions to them. <br>
You can create NPCs with one of the following functions:

"give" = NPC gives player items / weapons / money <br>
"sell" = NPC takes items and pays amount of $ back <br>
"sell_weapon" = NPC takes weapon and pays amount of $ back and/or gives you items in return <br>
"exchange" = NPC takes items/money and gives items/weapons/money in return <br>
"nointeraction" = just an NPC, you can't interact with them <br>

------------------<br>

If you found a bug, if you have an idea for the <br>
next version, or if you simply need some help,<br>
join: https://discord.gg/DUax6SsEt2

------------------<br>

1) Add ``juSa_npc_rewards`` to your resources folder
2) Add ``ensure juSa_npc_rewards`` to your server.cfg
3) Start server

# Requirements
- vorp_core
- vorp_inventory
- vorp_api
- vorp_menu


# Framework
Currently this script only works with VORP.

# Support

If you want to support me, you can do this here: <br>
https://www.buymeacoffee.com/justSalkin

# Changelog

V 1.6 <br>
- NPC type “sell_weapon” added <br>
- added menu calls (you now need vorp_menu) <br>
- reworked old calls, replaced by StateBags <br>

V 1.5.1 <br>
- Fixed a bug where the exchange NPC always expected at least one item to give and one to take.

V 1.5 <br>
- new Debug Feature <br>
- give-weapons for "give" and "exchange" NPCs <br>
- reworked Discord webhook (should now work without problems) <br>
- cooldowns, in general or for each NPC individually <br>
-  job and -grade dependency <br>
- talking-time (fixes the bug that players are in talk-mode indefinitely) <br>
- internal structural changes, smoother processes, better presentation of information ingame and in Discord <br>


V 1.4.0 <br>
- added animations and scenarios

V 1.3.0 <br>
- fixed progressbar showing befor item amount is checked <br>
- added webhooks for single npcs <br>
- added progressbar for single npcs <br>
- added option to choose between right or left notify <br>
- added more infos showing when interact with an npc and option to say yes/no to a sell or exchange <br>

V 1.2.1  <br>
- fix exchange NPC <br>

V 1.2.0  <br>
- added nointeraction NPC-role

V 1.1.0 <br>
- added Blips <br>
set blip = 0 for an NPC to not display it on the map <br>


Hope you enjoying working with the script :)
