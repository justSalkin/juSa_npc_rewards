game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'justSalkin'
description 'Script for rewards from NPCs'
version '1.5.0'

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

-- for more infos or if you found a bug join the juSa script discord: https://discord.com/invite/bxJ3d2j4dH