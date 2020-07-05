local config = GM.Config.Drowning

local WATER_SUBMERGED = 3

-- TODO: Add Gear specific rules for scuba gear and similar

util.AddNetworkString( "RVR_Player_Enter_Water" )
util.AddNetworkString( "RVR_Player_Leave_Water" )
util.AddNetworkString( "RVR_Player_Take_Drown_Damage" )

local function isDrowning( player )
    return ( CurTime() - player.FirstSubmergedTime ) >= config.DROWNING_THRESHOLD
end

local function canTakeDrownDamage( player )
    return ( CurTime() - player.LastDrownTick ) >= config.DROWNING_TICK_DELAY
end

local function takeDrownDamage( player )
    if not canTakeDrownDamage( player ) then return end

    player.LastDrownTick = CurTime()

    local dmg = DamageInfo()
    dmg:SetDamage( config.DROWNING_DAMAGE )
    dmg:SetDamageType( DMG_DROWN )

    player:TakeDamageInfo( dmg )
end

local function alertPlayerOfEnterWater( player, time )
    net.Start( "RVR_Player_Enter_Water" )
        net.WriteFloat( time )
    net.Send( player )
end

local function alertPlayerOfLeaveWater( player )
    net.Start( "RVR_Player_Leave_Water" )
    net.Send( player )
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
