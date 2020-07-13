RVR.PlayerDeath = RVR.PlayerDeath or {}
local death = RVR.PlayerDeath

hook.Add( "PlayerDeath", "RVR_Cooldown", function( ply )
    if ply.RVR_NextRespawn then return end

    ply.RVR_NextRespawn = CurTime() + GAMEMODE.Config.PlayerDeath.RESPAWN_TIME
end )

hook.Add( "RVR_PlayerCanSpawn", "RVR_Cooldown", function( ply )
    if ply.RVR_NextRespawn and ply.RVR_NextRespawn > CurTime() then
        return false
    end
end )

hook.Add( "RVR_SuccessfulPlayerSpawn", "RVR_Cooldown", function( ply )
    ply.RVR_NextRespawn = nil
end )
