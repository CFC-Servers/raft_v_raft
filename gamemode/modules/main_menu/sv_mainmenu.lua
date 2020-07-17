util.AddNetworkString( "RVR_MainMenu_SetModel" )

net.Receive( "RVR_MainMenu_SetModel", function( len, ply )
    local model = net.ReadString()

    if not table.HasValue( GAMEMODE.Config.Generic.PLAYER_MODELS, model ) then
        return
    end

    ply:SetModel( model )
    ply.PlayerModel = model
end )
