local config = GM.Config.Drowning

local WATER_SUBMERGED = 3

-- TODO: Add Gear specific rules for scuba gear and similar

util.AddNetworkString( "RVR_Player_Enter_Water" )
util.AddNetworkString( "RVR_Player_Leave_Water" )
util.AddNetworkString( "RVR_Player_Take_Drown_Damage" )

local function isDrowning( ply )
    return ( CurTime() - ply.FirstSubmergedTime ) >= config.DROWNING_THRESHOLD
end

local function canTakeDrownDamage( ply )
    return ( CurTime() - ply.LastDrownTick ) >= config.DROWNING_TICK_DELAY
end

local function takeDrownDamage( ply )
    if not canTakeDrownDamage( ply ) then return end

    ply.LastDrownTick = CurTime()

    local dmg = DamageInfo()
    dmg:SetDamage( config.DROWNING_DAMAGE )
    dmg:SetDamageType( DMG_DROWN )
    dmg:SetAttacker( ply )

    ply:TakeDamageInfo( dmg )
end

local function alertPlayerOfEnterWater( ply, time )
    net.Start( "RVR_Player_Enter_Water" )
        net.WriteFloat( time )
    net.Send( ply )
end

local function alertPlayerOfLeaveWater( ply )
    net.Start( "RVR_Player_Leave_Water" )
    net.Send( ply )
end

local function drowningCheck()
    for _, ply in pairs( player.GetHumans() ) do
        if ply:WaterLevel() == WATER_SUBMERGED and ply:Alive() then
            if not ply.IsInWater then
                ply.IsInWater = true

                local time = CurTime()
                ply.FirstSubmergedTime = time
                ply.LastDrownTick = 0

                alertPlayerOfEnterWater( ply, time )
            end

            if isDrowning( ply ) then
                takeDrownDamage( ply )
            end
        else
            if ply.IsInWater then
                alertPlayerOfLeaveWater( ply )
            end

            ply.IsInWater = false
        end
    end
end

hook.Add( "Tick", "RVR_Check_Drowning", drowningCheck )

local function onPlayerTakeDrownDamage( ply, dmg )
    if not IsValid( ply ) or not ply:IsPlayer() then return end
    if dmg:GetDamageType() ~= DMG_DROWN then return end

    net.Start( "RVR_Player_Take_Drown_Damage" )
    net.Send( ply )
end

hook.Add( "EntityTakeDamage", "RVR_Take_Drown_Damage", onPlayerTakeDrownDamage )
