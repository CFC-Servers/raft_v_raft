AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

resource.AddFile( "resource/fonts/bungee_regular.ttf" )

-- Needed to show holding animations, to be remove when main menu implemented
function GM:PlayerSetModel( ply )
    ply:SetModel( "models/player/odessa.mdl" )
end

include( "load_assets.lua" )
