AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

-- Configs
include( "config/drowning.lua" )
AddCSLuaFile( "config/drowning.lua" )

-- Modules
include( "modules/drowning/sv_drowning.lua" )
AddCSLuaFile( "modules/drowning/cl_drowning.lua" )
