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
net.Receive( "RVR_Party_updateFriends", sendFriendData )

hook.Add( "PreDrawHalos", "RVR_Party", function()
    local ownParty = LocalPlayer():GetParty()

    if not ownParty then return end
    halo.Add( ownParty.members, ownParty.color, 5, 5, 2 )
end )

local function drawNameLabel( ply, textColor )
    local me = LocalPlayer()

    local diff = me:GetShootPos() - ply:GetShootPos()
    local textAng = Angle( 0, diff:Angle().yaw + 90, 90 )
    local dist = diff:Length()

    local scale = math.Clamp( dist * 0.002, 0.5, 3 )

    local pos = ply:GetShootPos() + Vector( 0, 0, 5 + scale * 15 )
    local text = ply:Nick()

    cam.Start3D2D( pos, textAng, scale )
        surface.SetFont( "ChatFont" )
        local tw, th = surface.GetTextSize( text )
        draw.SimpleText( text, "ChatFont", -tw / 2, -th / 2, textColor ) -- try TEXT_ALIGN_CENTER
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
if hook.Run( "RVR_ShouldOverrideAddText" ) ~= false then
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
                        v,
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
