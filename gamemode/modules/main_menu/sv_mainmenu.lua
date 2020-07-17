util.AddNetworkString( "RVR_MainMenu_SetModel" )
util.AddNetworkString( "RVR_MainMenu_SpawnSelf" )

net.Receive( "RVR_MainMenu_SetModel", function( len, ply )
    local model = net.ReadString()
    local models = GAMEMODE.Config.Generic.PLAYER_MODELS

    if not table.HasValue( models, model ) then
        return
    end

    ply:SetModel( model )
    ply.PlayerModel = model
end )

net.Receive( "RVR_MainMenu_SpawnSelf", function( len, ply )
    if not ply:Alive() then
        ply:Spawn()
    end
end )
