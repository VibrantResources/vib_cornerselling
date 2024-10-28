fx_version 'cerulean'
game 'gta5'

description 'Modified version of qb-drugs Corner Selling using 3d text'
author 'Vibrant Resources'
version '1.0'

client_scripts {
	'client/*.lua',
}

server_scripts  {
	'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
	'config.lua',
}

lua54 'yes'