AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

resource.AddFile( "materials/icons/health.png" )
resource.AddFile( "materials/icons/water.png" )
resource.AddFile( "materials/icons/food.png" )
resource.AddFile( "materials/icons/equip_slot_hat.png" )
resource.AddFile( "materials/icons/equip_slot_pants.png" )
resource.AddFile( "materials/icons/equip_slot_shirt.png" )
resource.AddFile( "materials/icons/player_inventory_background.png" )
resource.AddFile( "materials/icons/slot_background.png" )
resource.AddFile( "materials/icons/wood.png" )
resource.AddFile( "materials/icons/player_inventory_close.png" )
resource.AddFile( "materials/icons/player_hotbar_background.png" )

function GM:PlayerSetModel( ply )
    ply:SetModel( "models/player/odessa.mdl" )
end