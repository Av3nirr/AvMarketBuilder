fx_version "adamant"
games {"gta5"}
lua54 'yes'
author "Av3nirr"

files {
    "zUI/menus/theme.json",
    "zUI/notifications/theme.json",
    "zUI/contextMenus/theme.json",
    "zUI/modals/theme.json",
    "zUI/user-interface/build/index.html",
    "zUI/user-interface/build/**/*"
}

ui_page "zUI/user-interface/build/index.html"

client_scripts {
    -- [[zUI]]
    "zUI/*.lua",
    "zUI/items/*.lua",
    "zUI/menus/_init.lua",
    "zUI/menus/menu.lua",
    "zUI/menus/methods/*.lua",
    "zUI/menus/functions/*.lua",
    "zUI/notifications/*.lua",
    "zUI/contextMenus/components/*.lua",
    "zUI/contextMenus/*.lua",
    "zUI/contextMenus/functions/*.lua",
    "zUI/modals/*.lua",
    
    "client/*.lua"
}

shared_scripts {
    'shared/*.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

lua54 'yes'