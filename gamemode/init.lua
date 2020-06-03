AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "modules/hud/cl_hud.lua" )
AddCSLuaFile( "modules/items/sh_items.lua" )
AddCSLuaFile( "modules/inventory/cl_inventory.lua" )
AddCSLuaFile( "modules/inventory/cl_itemslot.lua" )
AddCSLuaFile( "modules/inventory/cl_playerinventory.lua" )
AddCSLuaFile( "modules/inventory/cl_boxinventory.lua" )
AddCSLuaFile( "config/inventory.lua" )

include( "shared.lua" )

-- Configs
include( "config/drowning.lua" )
AddCSLuaFile( "config/drowning.lua" )

-- Modules
include( "modules/drowning/sv_drowning.lua" )
AddCSLuaFile( "modules/drowning/cl_drowning.lua" )

include( "modules/inventory/sv_inventory.lua" )

include( "modules/hunger/sv_hunger.lua" )

resource.AddFile( "materials/icons/health.png" )
resource.AddFile( "materials/icons/slot_background.png" )
resource.AddFile( "materials/icons/player_inventory_background.png" )
resource.AddFile( "materials/icons/player_inventory_close.png" )
