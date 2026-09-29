fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'SeaM_Npcs'
author 'SeaM'
description 'Standing NPCs you can talk to'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/quests.lua',
    'shared/dialogue.lua',
    'shared/points.lua',
}

client_scripts {
    'client/quests.lua',
    'client/main.lua',
}

server_scripts {
    'server/quests.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/*',
}

dependency 'SeaM_Core'
