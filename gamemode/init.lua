AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

resource.AddFile( "resource/fonts/bungee_regular.ttf" )

-- Needed to show holding animations, to be remove when main menu implemented
function GM:PlayerSetModel( ply )
    ply.PlayerModel = ply.PlayerModel or "models/player/odessa.mdl"
    ply:SetModel( ply.PlayerModel )
end

include( "load_assets.lua" )
