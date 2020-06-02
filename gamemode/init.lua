AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

AddCSLuaFile( "modules/items/sh_items.lua" )
AddCSLuaFile( "modules/inventory/cl_inventory.lua" )
AddCSLuaFile( "modules/inventory/cl_itemslot.lua" )
AddCSLuaFile( "modules/inventory/cl_playerinventory.lua" )
AddCSLuaFile( "modules/inventory/cl_boxinventory.lua" )
AddCSLuaFile( "config/inventory.lua" )

resource.AddFile( "materials/slot_background.png" )

include( "modules/inventory/sv_inventory.lua" )