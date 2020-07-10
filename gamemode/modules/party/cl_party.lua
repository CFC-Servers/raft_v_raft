RVR.Party = RVR.Party or {}
local party = RVR.Party

function party.tryCreateParty( name, tag, color, joinMode, callback )
    if joinMode < 0 or joinMode > 2 then return end
    if party.createPartyCallback then return end

    net.Start( "RVR_Party_createParty" )
        net.WriteString( name )
        net.WriteString( tag )
        net.WriteColor( color )
        net.WriteUInt( joinMode, 2 )
    net.SendToServer()

    party.createPartyCallback = callback
end

net.Receive( "RVR_Party_createParty", function()
    if not party.createPartyCallback then return end

    local success = net.ReadBool()
    local err

    if not success then
        err = net.ReadString()
    end

    party.createPartyCallback( success, err )
    party.createPartyCallback = nil
end )

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

local function sendFriendData()
    local friends = {}
    for _, ply in pairs( player.GetAll() ) do
        if ply:GetFriendStatus() == "friend" then
            table.insert( friends, ply )
        end
    end

    if #friends == 0 then return end

    net.Start( "RVR_Party_updateFriends" )
        net.WriteTable( friends )
    net.SendToServer()
end

hook.Add( "InitPostEntity", "RVR_Party_sendFriendData", sendFriendData )
hook.Add( "PlayerConnect", "RVR_Party_sendFriendData", sendFriendData )
