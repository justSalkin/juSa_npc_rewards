game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'justSalkin'
description 'Script for rewards from NPCs'
version '1.3.0'

client_script {
    'main.lua', 
}

server_script {
    'server.lua', 
}

shared_scripts {
    'config.lua',
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    'vorp_progressbar'
}

-- for support and/or more scripts join: https://discord.gg/DUax6SsEt2