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

-- TODO: Add some way to trigger a manual update, or trigger updates in a timer

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

hook.Add( "PreDrawHalos", "RVR_Party", function()
    local members = {}
    local ownParty = LocalPlayer():GetPartyID()

    if not ownParty then return end
    for _, ply in pairs( player.GetAll() ) do
        if ply ~= LocalPlayer() and ply:GetPartyID() == ownParty then
            table.insert( members, ply )
        end
    end

    halo.Add( members, Color( 0, 255, 0 ), 5, 5, 2 )
end )

local function drawNameLabel( ply )
    local me = LocalPlayer()

    local ang = ( ply:GetShootPos() - me:GetShootPos() ):Angle()
    local textAng = Angle( 0, ang.yaw, 0 )

    local pos = ply:GetShootPos() + Vector( 0, 0, 30 )
    local text = ply:Nick()

    cam.Start3D2D( pos, textAng, 0.2 )
        surface.SetFont( "ChatFont" )
        local tw, th = surface.GetTextSize( text )
        draw.SimpleText( text, "ChatFont", -tw / 2, -th / 2, Color( 0, 255, 0 ) ) -- try TEXT_ALIGN_CENTER
    cam.End3D2D()
end

hook.Add( "PostDrawOpaqueRenderables", "RVR_Party", function()
    local ownParty = LocalPlayer():GetPartyID()

    if not ownParty then return end
    for _, ply in pairs( player.GetAll() ) do
        if ply ~= LocalPlayer() and ply:GetPartyID() == ownParty then
            drawNameLabel( ply )
        end
    end
end )
