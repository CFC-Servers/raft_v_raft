RVR.Party = RVR.Party or {}
local party = RVR.Party
party.idCounter = party.idCounter or 0

-- TODO: Start player as spectator

party.JOIN_MODE_PUBLIC = 0
party.JOIN_MODE_STEAM_FRIENDS = 1
party.JOIN_MODE_INVITE_ONLY = 2

party.joinModeStrs = {
    [0] = "public",
    [1] = "steam-friends only",
    [2] = "invite only",
}

util.AddNetworkString( "RVR_Party_updateClient" )
util.AddNetworkString( "RVR_Party_createParty" )
util.AddNetworkString( "RVR_Party_updateFriends" )

local function updateClientPartyData( id )
    local partyData = party.getParty( id )

    net.Start( "RVR_Party_updateClient" )
        net.WriteUInt( id, 32 )
        net.WriteBool( tobool( partyData ) )
        if partyData then
            net.WriteTable( partyData )
        end
    net.Broadcast()
end

function party.createParty( partyName, owner, tag, color, joinMode )
    for id, partyData in pairs( party.parties ) do
        if partyData.name == partyName then
            return nil, "Party with name " .. partyName .. " already exists"
        end
        if partyData.tag == tag then
            return nil, "Party with tag " .. tag .. " already exists"
        end
    end

    if owner:GetPartyID() then
        return nil, "Player " .. owner:Nick() .. " already in a party"
    end

    if #tag ~= 4 then
        return nil, "Tag must be 4 characters"
    end

    if #partyName < 5 or tonumber( partyName ) then
        return nil, "Invalid party name, must be at least 5 characters and contain at least one non-numeric character"
    end

    if color.a ~= 255 then
        return nil, "Party color alpha must be 255 (ff)"
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
        invites = {},
    }

    party.parties[id] = partyData

    owner:SetPartyID( id )

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

    if mode < 0 or mode > 2 then
        return false, "Invalid join mode"
    end

    partyData.joinMode = mode
    party.broadcastMessage( partyData.id, "Party join mode has been set to " .. party.joinModeStrs[mode] )
end

-- TODO: Drop inventory, switch to spectator
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

-- TODO: Teleport to raft
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

    -- TODO: Add cooldown
    partyData.invites[ply] = CurTime()

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

    local success, err = party.createParty( name, ply, tag, color, joinMode )

    net.Start( "RVR_Party_createParty" )
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
