RVR.Party = RVR.Party or {}
local party = RVR.Party

net.Receive( "RVR_Party_updateClient", function()
    local id = net.ReadInt( 32 )
    local partyExists = net.ReadBool()
    if partyExists then
        local partyData = net.ReadTable()
        party.parties[id] = partyData
    else
        party.parties[id] = nil
    end
end )
