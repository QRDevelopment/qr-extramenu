--[[ Resource Information ]]--
name 'qr-extramenu'
version '1.0.0'
author 'qr-development'
description 'police vehicle extra menu by QR'

--[[ Resource Settings ]]--
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/main.js',
    'html/style.css'
}
