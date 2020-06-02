local firstSubmergedTime, lastDrownTick = {}
local Config = GM.Config.Drowning

local WATER_SUBMERGED = 3

-- TODO: Add Gear specific rules for scuba gear and similar

util.AddNetworkString( "RVR_Player_Enter_Water" )
util.AddNetworkString( "RVR_Player_Leave_Water" )

local function isDrowning( player )
    return ( CurTime() - firstSubmergedTime[player:SteamID()] ) >= Config.DROWNING_THRESHOLD
end

local function canTakeDrownDamage( player )
    return ( CurTime() - lastDrownTick[player:SteamID()] ) >= Config.DROWNING_TICK_DELAY
end

local function takeDrownDamage( player )
    if not canTakeDrownDamage( player ) then return end

    lastDrownTick[player:SteamID()] = CurTime()

    local dmg = DamageInfo()
    dmg:SetDamage( Config.DROWNING_DAMAGE )
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
        local plySteamID = ply:SteamID()

        if ply:WaterLevel() == WATER_SUBMERGED then
            if not firstSubmergedTime[plySteamID] then
                local time = CurTime()
                firstSubmergedTime[plySteamID] = time
                lastDrownTick[plySteamID] = 0

                alertPlayerOfEnterWater( ply, time )
            end

            if isDrowning( ply ) then
                takeDrownDamage( ply )
            end
        else

            firstSubmergedTime[plySteamID] = nil
            lastDrownTick[plySteamID] = nil

            alertPlayerOfLeaveWater( ply )
        end
    end
end

hook.Add( "Tick", "RVR_Check_Drowning", drowningCheck )

local function deleteDrowningData( player )
    local plySteamID = player:SteamID()

    firstSubmergedTime[plySteamID] = nil
    lastDrownTick[plySteamID] = nil
end

hook.Add( "PlayerDisconnected", "RVR_Delete_Drowning", deleteDrowningData )
