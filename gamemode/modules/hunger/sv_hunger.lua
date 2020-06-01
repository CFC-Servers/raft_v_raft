local MAX_HUNGER = 100 -- TODO extract this into a global config table
local HUNGER_DELAY = 5
local HUNGER_LOSS_AMOUNT = -1
local HUNGER_DAMAGE_AMOUNT = 10

hook.Add("PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetHunger( MAX_HUNGER )
end)

timer.Create( "rvr_hunger_subtract", HUNGER_DELAY, 0, function()
    for _, ply in pairs( player.GetHumans() ) do
        ply:AddHunger(HUNGER_LOSS_AMOUNT)
    
        -- TODO seperate timer
        if ply:GetHunger() <= 0 then
            ply:TakeDamage( HUNGER_DAMAGE_AMOUNT )
        end
    end
end )

