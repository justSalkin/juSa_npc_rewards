game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'justSalkin'
description 'Script for rewards from NPCs'
version '1.2.1'


client_script {
    'main.lua', 
}

server_script {
    'server.lua', 
}

shared_scripts {
    'config.lua',
}

dependency 'vorp_core'
dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_progressbar'
}

-- LAST EDIT by just_Salkin 15.01.2023 | WHITE-SANDS-RP german RP server
-- credits to Skildome ^^ helped me a lot when i had questions