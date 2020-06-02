local MAX_FOOD = 100 -- TODO extract this into a global config table
local MAX_WATER = 100

local DELAY = 5

local WATER_LOSS_AMOUNT = -1
local FOOD_LOSS_AMOUNT = -1
local DAMAGE_AMOUNT = 10

hook.Add( "PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetFood( MAX_HUNGER )
    ply:SetWater( MAX_WATER )
end )

timer.Create( "rvr_hunger_subtract", DELAY, 0, function()
    for _, ply in pairs( player.GetHumans() ) do
        
        ply:AddFood( FOOD_LOSS_AMOUNT )
        ply:AddWater( WATER_LOSS_AMOUNT )

        -- TODO seperate timer
        if ply:GetFood() <= 0 then
            ply:TakeDamage( DAMAGE_AMOUNT )
        end
    end
end )

