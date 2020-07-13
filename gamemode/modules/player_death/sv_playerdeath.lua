RVR.PlayerDeath = RVR.PlayerDeath or {}
local death = RVR.PlayerDeath

util.AddNetworkString( "RVR_PlayerDeath" )

-- Create our own RVR_PlayerDeath event which is shared, not relaying normal PlayerDeath as some other addons may do this
-- Could lead to duplicate calls
hook.Add( "PlayerDeath", "RVR_RelayPlayerDeath", function( victim, inflictor, attacker )
    hook.Run( "RVR_PlayerDeath", victim, inflictor, attacker )

    net.Start( "RVR_PlayerDeath" )
        net.WriteEntity( victim )
        net.WriteEntity( inflictor or game.GetWorld() )
        net.WriteEntity( attacker or game.GetWorld() )
    net.Broadcast()

    if RVR.Inventory.isEmpty( victim ) then return end

    local deathBox = ents.Create( "rvr_death_box" )
    deathBox:SetPos( victim:GetPos() )
    deathBox:Spawn()
    deathBox:TakeFromPlayer( victim )
end )

hook.Add( "RVR_Inventory_Close", "RVR_PlayerDeath_DeleteEmptyBoxes", function( ply, ent )
    if ent:GetClass() ~= "rvr_death_box" then return end

    if RVR.Inventory.isEmpty( ent ) then
        ent:Remove()
    end
end )
