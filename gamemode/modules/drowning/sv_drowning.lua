local firstSubmergedTime = {}
local lastDrownTick = {}
local config = GM.Config.Drowning

local WATER_SUBMERGED = 3

-- TODO: Add Gear specific rules for scuba gear and similar

util.AddNetworkString( "RVR_Player_Enter_Water" )
util.AddNetworkString( "RVR_Player_Leave_Water" )
util.AddNetworkString( "RVR_Player_Take_Drown_Damage" )

local function isDrowning( player )
    return ( CurTime() - firstSubmergedTime[player:SteamID()] ) >= config.DROWNING_THRESHOLD
end

local function canTakeDrownDamage( player )
    return ( CurTime() - lastDrownTick[player:SteamID()] ) >= config.DROWNING_TICK_DELAY
end

local function takeDrownDamage( player )
    if not canTakeDrownDamage( player ) then return end

    lastDrownTick[player:SteamID()] = CurTime()

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
        local plySteamID = ply:SteamID()

        if ply:WaterLevel() == WATER_SUBMERGED and ply:Alive() then
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

local function onPlayerTakeDrownDamage( ply, dmg )
    if not IsValid( ply ) or not ply:IsPlayer() then return end
    if dmg:GetDamageType() ~= DMG_DROWN then return end

    net.Start( "RVR_Player_Take_Drown_Damage" )
    net.Send( ply )
end

hook.Add( "EntityTakeDamage", "RVR_Take_Drown_Damage", onPlayerTakeDrownDamage )
