hook.Add( "PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetFood( GM.Config.MAX_FOOD )
    ply:SetWater( GM.Config.MAX_WATER )
end )

timer.Create( "rvr_hunger_subtract", GM.Config.HUNGER_DELAY, 0, function()
    for _, ply in pairs( player.GetHumans() ) do
        
        ply:AddFood( GM.Config.FOOD_LOSS_AMOUNT )
        ply:AddWater( GM.Config.WATER_LOSS_AMOUNT )

        -- TODO seperate timer
        if ply:GetFood() <= 0 then
            ply:TakeDamage( GM.Config.HUNGER_DAMAGE_AMOUNT )
        end
    end
end )

