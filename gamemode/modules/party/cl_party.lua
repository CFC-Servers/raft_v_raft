RVR.Party = RVR.Party or {}
local party = RVR.Party
party.invites = {}

local mouseEnabled = false
hook.Add( "PlayerBindPress", "RVR_Party_freeCursor", function( ply, bind, pressed )
    if not ( pressed and bind == "gm_showspare1" ) then return end

    mouseEnabled = not mouseEnabled
    gui.EnableScreenClicker( mouseEnabled )
end )

function party.tryCreateParty( name, tag, color, joinMode, callback )
    if not party.joinModeStrs[joinMode] then return end
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
    local err, errType

    if not success then
        err = net.ReadString()
        errType = net.ReadString()
    end

    party.createPartyCallback( success, err, errType )
    party.createPartyCallback = nil
end )

net.Receive( "RVR_Party_updateClient", function()
    local id = net.ReadInt( 32 )
    local partyExists = net.ReadBool()
    if partyExists then
        local partyData = net.ReadTable()
        party.parties[id] = partyData
        hook.Run( "RVR_Party_PartyChanged", id, partyData )
    else
        party.parties[id] = nil
        hook.Run( "RVR_Party_PartyChanged", id )
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

hook.Add( "InitPostEntity", "RVR_Party_sendFriendData", function()
    sendFriendData()
    net.Start( "RVR_Party_requestFullUpdate" )
    net.SendToServer()
end )
net.Receive( "RVR_Party_updateFriends", sendFriendData )
timer.Create( "RVR_Party_updateFriends", 300, 0, sendFriendData )

net.Receive( "RVR_Party_requestFullUpdate", function()
    party.parties = net.ReadTable()
end )

hook.Add( "PreDrawHalos", "RVR_Party", function()
    local ownParty = LocalPlayer():GetParty()

    if not ownParty then return end
    members = {}
    for _, member in pairs( ownParty.members ) do
        if IsValid( member ) and member:Alive() then
            table.insert( members, member )
        end
    end
    halo.Add( members, ownParty.color, 5, 5, 2 )
end )

local function drawNameLabel( ply, textColor )
    local localPly = LocalPlayer()

    local diff = localPly:GetShootPos() - ply:GetShootPos()
    local textAng = Angle( 0, diff:Angle().yaw + 90, 90 )
    local dist = diff:Length()

    local scale = math.Clamp( dist * 0.002, 0.5, 3 )

    local pos = ply:GetShootPos() + Vector( 0, 0, 5 + scale * 15 )
    local text = ply:Nick()

    cam.Start3D2D( pos, textAng, scale )
        draw.SimpleText( text, "ChatFont", 0, 0, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end

hook.Add( "PostDrawOpaqueRenderables", "RVR_Party", function()
    local ownParty = LocalPlayer():GetParty()

    if not ownParty then return end
    for _, ply in pairs( ownParty.members ) do
        if IsValid( ply ) and ply ~= LocalPlayer() then
            drawNameLabel( ply, ownParty.color )
        end
    end
end )

-- Allow other addons to prevent this, to do it themself
if GM.Config.Party.OVERRIDE_CHAT_ADD then
    party.oldAddText = party.oldAddText or chat.AddText

    function chat.AddText( ... )
        local out = {}
        local prevColor = Color( 255, 255, 255 )

        for _, v in ipairs( { ... } ) do
            if type( v ) == "Player" then
                local partyData = v:GetParty()

                if partyData then
                    table.Add( out, {
                        partyData.color,
                        "[" .. partyData.tag .. "] ",
                        prevColor,
                        v
                    } )
                else
                    table.insert( out, v )
                end
            else
                if IsColor( v ) then
                    prevColor = v
                end
                table.insert( out, v )
            end
        end

        party.oldAddText( unpack( out ) )
    end
end

hook.Add( "RVR_TargetID", "RVR_Party", function( ply, x, y )
    local partyData = ply:GetParty()
    if not partyData then return end

    local font = "TargetID"
    surface.SetFont( font )

    local partyName = partyData.name
    local partyW, partyH = surface.GetTextSize( partyName )
    local partyX = x - partyW / 2
    local partyY = y - partyH - 5

    draw.SimpleText( partyName, font, partyX + 1, partyY + 1, Color( 0, 0, 0, 120 ) )
    draw.SimpleText( partyName, font, partyX + 2, partyY + 2, Color( 0, 0, 0, 50 ) )
    draw.SimpleText( partyName, font, partyX, partyY, partyData.color )
end )

hook.Add( "CreateMove", "RVR_Party_PreventSpawn", function( cmd )
    if LocalPlayer():Alive() then return end
    if hook.Run( "RVR_PlayerCanSpawn", LocalPlayer() ) ~= false then return end

    cmd:ClearButtons()
    cmd:ClearMovement()
end )

net.Receive( "RVR_Party_inviteSent", function()
    local partyID = net.ReadUInt( 32 )
    local inviter = net.ReadEntity()

    party.invites[partyID] = CurTime()

    hook.Run( "RVR_Party_gotInvite", partyID, inviter )
end )
