RVR.Party = RVR.Party or {}
local party = RVR.Party
party.idCounter = party.idCounter or 0

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

function party.createParty( partyName, owner, tag )
    if party.getByName( partyName ) then
        return nil, "Party with name " .. partyName .. " already exists"
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

function party.addMember( id, ply )
    local partyData = party.getParty( id )

    if not partyData then
        return false, "Party with id " .. id .. " does not exist"
    end

    if ply:GetPartyID() then
        return false, "Player already in another party"
    end

    if table.HasValue( partyData.members, ply ) then
        return false, "Player already in this party"
    end

    table.insert( partyData.member, ply )

    updateClientPartyData( id )

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

hook.Add( "PlayerDisconnected", "RVR_Party", function( ply )
    local id = ply:GetPartyID()
    if not id then return end

    party.removeMember( id, ply )
end )
