RVR.Party = RVR.Party or {}
local party = RVR.Party
party.idCounter = party.idCounter or 0

util.AddNetworkString( "RVR_Party_updateClient" )
util.AddNetworkString( "RVR_Party_inviteSent" )
util.AddNetworkString( "RVR_Party_createParty" )
util.AddNetworkString( "RVR_Party_joinParty" )
util.AddNetworkString( "RVR_Party_updateFriends" )

local function updateClientPartyData( id )
    local partyData = party.getParty( id )

    net.Start( "RVR_Party_updateClient" )
        net.WriteUInt( id, 32 )
        net.WriteBool( partyData ~= nil )
        if partyData then
            net.WriteTable( partyData )
        end
    net.Broadcast()
end

function party.createParty( partyName, owner, tag, color, joinMode )
    if owner:GetPartyID() then
        return nil, "Player " .. owner:Nick() .. " already in a party"
    end

    if #tag ~= 4 then
        return nil, "Tag must be 4 characters"
    end

    local minLen = GAMEMODE.Config.Party.MIN_PARTY_NAME_LENGTH
    local maxLen = GAMEMODE.Config.Party.MAX_PARTY_NAME_LENGTH
    if #partyName < minLen or #partyName > maxLen or tonumber( partyName ) then
        return nil, "Party name must be between " .. minLen .. " and " ..
            maxLen .. " characters and contain at least one letter"
    end

    if color.a ~= 255 then
        return nil, "Party color alpha must be 255 (ff)"
    end

    for id, partyData in pairs( party.parties ) do
        if partyData.name == partyName then
            return nil, "Party with name " .. partyName .. " already exists", "name"
        end
        if partyData.tag == tag then
            return nil, "Party with tag " .. tag .. " already exists", "tag"
        end
    end

    local id = party.idCounter
    party.idCounter = party.idCounter + 1
    local partyData = {
        name = partyName,
        owner = owner,
        members = { owner },
        id = id,
        tag = tag,
        color = color,
        joinMode = joinMode,
        invites = {}
    }

    party.parties[id] = partyData

    owner:SetPartyID( id )

    hook.Run( "RVR_Party_PartyCreated", partyData )

    updateClientPartyData( id )

    return id, partyData
end

function party.removeParty( id )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    for _, ply in pairs( partyData.members ) do
        ply:SetPartyID( nil )
    end

    party.parties[id] = nil

    hook.Run( "RVR_Party_PartyRemoved", partyData )

    updateClientPartyData( id )

    return true
end

function party.broadcastMessage( id, msg )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    for _, member in pairs( partyData.members ) do
        member:ChatPrint( msg )
    end

    return true
end

function party.setJoinMode( id, mode )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if not party.joinModeStrs[mode] then
        return false, "Invalid join mode"
    end

    partyData.joinMode = mode
    party.broadcastMessage( partyData.id, "Party join mode has been set to " .. party.joinModeStrs[mode] )

    updateClientPartyData( id )

    return true
end

function party.removeMember( id, ply )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if ply:GetPartyID() ~= id then
        return false, "Player not in this party"
    end

    ply:SetPartyID( nil )
    table.RemoveByValue( partyData.members, ply )

    party.broadcastMessage( partyData.id, ply:Nick() .. " has left the party." )

    if #partyData.members == 0 then
        party.removeParty( id )
        return true
    end

    if partyData.owner == ply then
        partyData.owner = partyData.members[1]

        party.broadcastMessage( partyData.id, "The owner ( " .. ply:Nick() .. " has left this party, " .. partyData.owner:Nick() .. " is the new owner." )
    end

    updateClientPartyData( id )

    return true
end

function party.addMember( id, ply )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if table.HasValue( partyData.members, ply ) then
        return false, "Player already in this party"
    end

    if #partyData.members == GAMEMODE.Config.Party.MAX_PLAYERS then
        return false, "Party is full"
    end

    if ply:GetPartyID() then
        party.removeMember( ply:GetPartyID(), ply )
    end

    party.broadcastMessage( partyData.id, ply:Nick() .. " has joined the party!" )

    ply:SetPartyID( id )
    table.insert( partyData.members, ply )

    updateClientPartyData( id )

    return true
end

function party.attemptJoin( id, ply )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if table.HasValue( partyData.members, ply ) then
        return false, "Player already in party"
    end

    if partyData.joinMode == party.JOIN_MODE_PUBLIC then
        party.addMember( id, ply )
        return true
    end

    if partyData.joinMode == party.JOIN_MODE_STEAM_FRIENDS and partyData.owner:IsFriendsWith( ply ) then
        party.addMember( id, ply )
        return true
    end

    local inviteTime = partyData.invites[ply]
    if inviteTime then
        local cTime = CurTime()
        partyData.invites[ply] = nil
        if cTime - inviteTime < GAMEMODE.Config.Party.INVITE_LIFETIME then
            party.addMember( id, ply )
            return true
        else
            return false, "Invite expired " .. ( cTime - inviteTime - GAMEMODE.Config.Party.INVITE_LIFETIME ) .. " seconds ago"
        end
    end

    return false, "This party is not public and you don't have an invite"
end

function party.invite( id, inviter, ply )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if partyData.owner ~= inviter then
        return false, "Only the owner of a party can invite a player"
    end

    if table.HasValue( partyData.members, ply ) then
        return false, "Player already in party"
    end

    if #partyData.members == GAMEMODE.Config.Party.MAX_PLAYERS then
        return false, "Party is full"
    end

    if inviter.RVR_Party_lastInvite then
        if CurTime() - inviter.RVR_Party_lastInvite < GAMEMODE.Config.Party.INVITE_COOLDOWN then
            return false, "Invite cooldown has not yet passed"
        end
    end

    inviter.RVR_Party_lastInvite = CurTime()

    partyData.invites[ply] = CurTime()

    net.Start( "RVR_Party_inviteSent" )
        net.WriteUInt( id, 32 )
        net.WriteEntity( inviter )
    net.Send( ply )

    return true
end

local plyMeta = FindMetaTable( "Player" )

function plyMeta:SetPartyID( partyID )
    if partyID and not party.getParty( partyID ) then
        error( "Party with ID " .. partyID .. " does not exist" )
    end
    self:SetNWInt( "RVR_Party_ID", partyID or -1 )
end

function plyMeta:SetParty( partyData )
    self:SetPartyID( partyData.id )
end

function plyMeta:IsFriendsWith( ply )
    if not self.RVR_Friends then return false end

    return table.HasValue( self.RVR_Friends, ply )
end

hook.Add( "PlayerDisconnected", "RVR_Party", function( ply )
    local id = ply:GetPartyID()
    if not id then return end

    party.removeMember( id, ply )

    for _, partyData in pairs( party.parties ) do
        partyData.invites[ply] = nil
    end
end )

net.Receive( "RVR_Party_createParty", function( len, ply )
    local name = net.ReadString()
    local tag = net.ReadString()
    local color = net.ReadColor()
    local joinMode = net.ReadUInt( 2 )

    if joinMode > 2 then return end

    local partyID, err, errType = party.createParty( name, ply, tag, color, joinMode )
    local success = partyID ~= nil
    errType = errType or "generic"

    net.Start( "RVR_Party_createParty" )
        net.WriteBool( success )
        if not success then
            net.WriteString( err )
            net.WriteString( errType )
        end
    net.Send( ply )
end )

net.Receive( "RVR_Party_joinParty", function( len, ply )
    local id = net.ReadUInt( 32 )

    local success, err = party.attemptJoin( id, ply )

    net.Start( "RVR_Party_joinParty" )
        net.WriteBool( success )
        if not success then
            net.WriteString( err )
        end
    net.Send( ply )
end )

net.Receive( "RVR_Party_updateFriends", function( len, ply )
    ply.RVR_Friends = net.ReadTable()
end )

hook.Add( "PlayerInitialSpawn", "RVR_Party_updateFriends", function()
    net.Start( "RVR_Party_updateFriends" )
    net.Broadcast()
end )

hook.Add( "PlayerCanSeePlayersChat", "RVR_Party_chat", function( text, isTeam, listener, speaker )
    if not isTeam then return end

    return speaker:IsInSameParty( listener )
end )

hook.Add( "PlayerShouldTakeDamage", "RVR_Party_friendlyFire", function( ply, attacker )
    if GAMEMODE.Config.Party.ALLOW_FRIENDLY_FIRE then return end
    if ply ~= attacker and type( attacker ) == "Player" and ply:IsInSameParty( attacker ) then
        return false
    end
end )

hook.Add( "PlayerInitialSpawn", "RVR_Party", function( ply )
    ply:KillSilent()
    timer.Simple( 0.1, function()
        ply:KillSilent()
    end )
end )

hook.Add( "PlayerSpawn", "RVR_Party_PreventSpawn", function( ply )
    if hook.Run( "RVR_PlayerCanSpawn", ply ) ~= false then
        hook.Run( "RVR_SuccessfulPlayerSpawn", ply )
        return
    end

    ply:KillSilent()
    timer.Simple( 0.1, function()
        ply:KillSilent()
    end )
end )

hook.Add( "RVR_SuccessfulPlayerSpawn", "RVR_Party_Raft_Spawn", function( ply )
    local partyData = ply:GetParty()
    if not partyData then return end -- This should never happen, but just to be sure.
    
    local raft = RVR.getRaft( partyData.raftID )
    
    local spawnPos = raft:GetSpawnPosition( ply )

    ply:SetPos( spawnPos )
end )
