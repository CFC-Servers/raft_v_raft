AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "modules/hud/cl_hud.lua" )

include( "shared.lua" )

-- Configs
include( "config/drowning.lua" )
AddCSLuaFile( "config/drowning.lua" )

-- Modules
include( "modules/drowning/sv_drowning.lua" )
AddCSLuaFile( "modules/drowning/cl_drowning.lua" )

include( "modules/hunger/sv_hunger.lua" )

resource.AddFile( "materials/icons/health.png" )
