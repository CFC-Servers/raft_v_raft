RVR.Party = RVR.Party or {}
local party = RVR.Party
party.parties = party.parties or {}

party.JOIN_MODE_PUBLIC = 0
party.JOIN_MODE_STEAM_FRIENDS = 1
party.JOIN_MODE_INVITE_ONLY = 2

party.joinModeStrs = {
    [0] = "public",
    [1] = "steam-friends only",
    [2] = "invite only",
}

function party.getParty( id )
    return party.parties[id]
end

function party.getByName( name )
    for id, partyData in pairs( party.parties ) do
        if partyData.name == name then
            return partyData
        end
    end
end

local plyMeta = FindMetaTable( "Player" )

function plyMeta:GetPartyID()
    local id = self:GetNWInt( "RVR_Party_ID", -1 )
    if id == -1 then return end
    return id
end

function plyMeta:GetParty()
    local id = self:GetPartyID()
    if not id then return end

    return party.getParty( id )
end

function plyMeta:GetPartyTag()
    local partyData = self:GetParty()
    if not partyData then return nil end

    return partyData.tag
end

function plyMeta:IsInSameParty( ply )
    return self:GetPartyID() ~= nil and self:GetPartyID() == ply:GetPartyID()
end

hook.Add( "RVR_PlayerCanSpawn", "RVR_NoPartyRespawnPrevent", function( ply )
    if not ply:GetPartyID() then return false end
end )
