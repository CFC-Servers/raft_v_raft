local config = GM.Config.Hunger

hook.Add( "PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetFood( config.MAX_FOOD )
    ply:SetWater( config.MAX_WATER )
end )

timer.Create( "rvr_hunger_subtract", config.DELAY, 0, function()
    for _, ply in pairs( player.GetHumans() ) do
        
        ply:AddFood( config.FOOD_LOSS_AMOUNT )
        ply:AddWater( config.WATER_LOSS_AMOUNT )

        -- TODO seperate timer
        if ply:GetFood() <= 0 then
            ply:TakeDamage( config.HUNGER_DAMAGE_AMOUNT )
        end
    end
end )

