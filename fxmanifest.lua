--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'wBunkers'
author       'STIFLER'
version      '1.0.0'
description  'Ownable bunkers made for the FiveM community by WHEREIAM'

--[[ Manifest ]]--

shared_script {'@es_extended/imports.lua','@ox_lib/init.lua', 'shared.lua'}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}