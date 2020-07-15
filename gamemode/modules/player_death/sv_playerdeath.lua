RVR.PlayerDeath = RVR.PlayerDeath or {}
local death = RVR.PlayerDeath

util.AddNetworkString( "RVR_PlayerDeath" )
util.AddNetworkString( "RVR_SuccessfulPlayerSpawn" )

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

hook.Add( "RVR_SuccessfulPlayerSpawn", "RVR_Cooldown", function( ply )
    net.Start( "RVR_SuccessfulPlayerSpawn" )
        net.WriteEntity( ply )
    net.Broadcast()
end )

hook.Add( "RVR_Inventory_Close", "RVR_PlayerDeath_DeleteEmptyBoxes", function( ply, ent )
    if ent:GetClass() ~= "rvr_death_box" then return end

    if RVR.Inventory.isEmpty( ent ) then
        ent:Remove()
    end
end )

hook.Add( "RVR_PreventInventory", "RVR_PlayerDeath", function( ply )
    if not ply:Alive() then return true end
end )

hook.Add( "RVR_PreventCraftingMenu", "RVR_PlayerDeath", function( ply )
    if not ply:Alive() then return true end
end )
