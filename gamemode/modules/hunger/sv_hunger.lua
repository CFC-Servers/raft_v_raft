local MAX_HUNGER = 100 -- TODO extract this into a global config table
local MAX_THIRST = 100

local DELAY = 5

local THIRST_LOSS_AMOUNT = -1
local HUNGER_LOSS_AMOUNT = -1
local DAMAGE_AMOUNT = 10

hook.Add( "PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetHunger( MAX_HUNGER )
    ply:SetThirst( MAX_THIRST )
end )

timer.Create( "rvr_hunger_subtract", HUNGER_DELAY, 0, function()
    for _, ply in pairs( player.GetHumans() ) do
        
        ply:AddHunger( HUNGER_LOSS_AMOUNT )
        ply:AddThirst( THIRST_LOSS_AMOUNT )

        -- TODO seperate timer
        if ply:GetHunger() <= 0 then
            ply:TakeDamage( DAMAGE_AMOUNT )
        end
    end
end )

