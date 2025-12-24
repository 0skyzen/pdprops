shared_script '@WaveShield/resource/include.lua'

fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.0'

shared_scripts {
	'@ox_lib/init.lua',
	'config/config_license.lua',
	'config/config_scanner.lua',
	'config/config_jail.lua',
	'shared/shared.lua'
}

server_scripts {
	'@es_extended/imports.lua',
	'@oxmysql/lib/MySQL.lua',
	'@mysql-async/lib/MySQL.lua',
	'server/license.lua',
	'server/scanner.lua',
	'server/pdprops.lua',
	'server/jail.lua'
}

client_scripts {
	'client/vhsText.lua',
	'client/scanner/*.lua',
	'client/pdprops/*.lua',
	'client/jail/*.lua'
}

ui_page 'ui/index.html'

files {
	'ui/**',
	'nui/**'
}

