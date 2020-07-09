RVR.Party = RVR.Party or {}
local party = RVR.Party
party.idCounter = party.idCounter or 0

-- TODO: extract to config
party.inviteLifetime = 30

util.AddNetworkString( "RVR_Party_updateClient" )

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

function party.createParty( partyName, owner, tag, isPublic )
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

    local id = party.idCounter
    party.idCounter = party.idCounter + 1
    local partyData = {
        name = partyName,
        owner = owner,
        members = { owner },
        id = id,
        tag = tag,
        public = tobool( isPublic ),
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

    if #partyData.members == 0 then
        party.removeParty( id )
        return true
    end

    if partyData.owner == ply then
        -- TODO: Alert somehow of ownership change
        partyData.owner = partyData.members[1]
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

    if ply:GetPartyID() then
        party.removeMember( ply:GetPartyID(), ply )
    end

    table.insert( partyData.member, ply )

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

    if partyData.public then
        party.addMember( id, ply )
        return true
    end

    local inviteTime = partyData.invites[ply]
    if inviteTime then
        local cTime = CurTime()
        partyData.invites[ply] = nil
        if cTime - inviteTime < party.inviteLifetime then
            party.addMember( id, ply )
            return true
        else
            return false, "Invite expired " .. ( cTime - inviteTime - party.inviteLifetime ) .. " seconds ago"
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

    -- TODO: Add cooldown
    partyData.invites[ply] = CurTime()
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

hook.Add( "PlayerDisconnected", "RVR_Party", function( ply )
    local id = ply:GetPartyID()
    if not id then return end

    party.removeMember( id, ply )

    for _, partyData in pairs( party.parties ) do
        partyData.invites[ply] = nil
    end
end )
