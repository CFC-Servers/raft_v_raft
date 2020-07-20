util.AddNetworkString( "RVR_MainMenu_SetModel" )
util.AddNetworkString( "RVR_MainMenu_SpawnSelf" )

net.Receive( "RVR_MainMenu_SetModel", function( len, ply )
    local model = net.ReadString()
    local models = GAMEMODE.Config.Generic.PLAYER_MODELS

    if not table.HasValue( models, model ) then
        return
    end

    ply:SetModel( model )
    ply.RVR_PlayerModel = model
end )

net.Receive( "RVR_MainMenu_SpawnSelf", function( len, ply )
    if not ply:Alive() and hook.Run( "RVR_PlayerCanSpawn", ply ) ~= false then
        ply:Spawn()
    end
end )
