AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

resource.AddFile( "materials/icons/health.png" )
resource.AddFile( "materials/icons/crafting_icon_background.png" )
resource.AddFile( "materials/icons/items/nail.png" )
resource.AddFile( "materials/crafting_background.png" )

resource.AddFile( "resource/fonts/bungee_regular.ttf" )

-- Needed to show holding animations, to be remove when main menu implemented
function GM:PlayerSetModel( ply )
    ply:SetModel( "models/player/odessa.mdl" )
end

include( "load_assets.lua" )
