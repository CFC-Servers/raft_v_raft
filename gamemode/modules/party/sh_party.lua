RVR.Party = RVR.Party or {}
local party = RVR.Party
party.parties = party.parties or {}

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
