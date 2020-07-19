RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

local joinPartyBg = Material( "rvr/backgrounds/mainmenu_joinpartybox.png" )
local joinPartyArrow = Material( "rvr/icons/mainmenu_joinpartyarrow.png" )

mainMenu.backgrounds = mainMenu.backgrounds or {}
mainMenu.backgrounds[mainMenu.MENU_JOIN] = Material( "rvr/backgrounds/mainmenu_join.png" )

function mainMenu.refreshJoinPartyList()
    if not mainMenu.frame then return end
    if mainMenu.page ~= mainMenu.MENU_JOIN then return end

    mainMenu.setMenuPage( mainMenu.MENU_JOIN, mainMenu.pageNum )
end

hook.Add( "RVR_Party_gotInvite", "RVR_MainMenu_UpdateList", function( id )
    if not mainMenu.frame then return end
    mainMenu.refreshJoinPartyList()
    timer.Simple( GAMEMODE.Config.Party.INVITE_LIFETIME + 0.5, mainMenu.refreshJoinPartyList )
end )

hook.Add( "RVR_Party_PartyChanged", "RVR_MainMenu_UpdateList", function()
    if not mainMenu.awaitingReply then
        mainMenu.refreshJoinPartyList()
    end
end )

net.Receive( "RVR_Party_joinParty", function()
    if not mainMenu.awaitingReply then return end
    if not mainMenu.frame then return end

    local success = net.ReadBool()

    if success then
        mainMenu.closeMenu()
        net.Start( "RVR_MainMenu_SpawnSelf" )
        net.SendToServer()
    else
        mainMenu.refreshJoinPartyList()
    end
end )

function mainMenu.fillPartiesList( partyBox, parties )
    mainMenu.awaitingReply = false

    for k, partyData in pairs( parties ) do
        local canJoin = false
        local textColor

        if partyData.joinMode == RVR.Party.JOIN_MODE_PUBLIC then
            canJoin = #partyData.members < GAMEMODE.Config.Party.MAX_PLAYERS
        else
            local inviteTime = RVR.Party.invites[partyData.id]
            local hasInvite = inviteTime and CurTime() - inviteTime < GAMEMODE.Config.Party.INVITE_LIFETIME

            if hasInvite then
                canJoin = true
                textColor = Color( 0, 130, 0 )
            elseif partyData.joinMode == RVR.Party.JOIN_MODE_STEAM_FRIENDS then
                if partyData.owner:GetFriendStatus() == "friend" then
                    canJoin = true
                end
            end
        end

        if table.HasValue( partyData.members, LocalPlayer() ) then
            canJoin = false
            textColor = nil
        end

        if not textColor then
            textColor = canJoin and mainMenu.darkBrown or Color( 160, 0, 0 )
        end

        local panel = vgui.Create( "DPanel", partyBox )
        panel:Dock( TOP )
        panel:DockMargin( 5, 5, 5, 5 )
        panel:SetTall( ScrH() * 0.025 )
        panel:SetMouseInputEnabled( true )
        panel:SetCursor( canJoin and "hand" or "no" )
        panel.Paint = nil

        function panel:OnMousePressed( btn )
            if btn ~= MOUSE_LEFT then return end
            if not canJoin then return end
            if mainMenu.awaitingReply then return end

            net.Start( "RVR_Party_joinParty" )
                net.WriteUInt( partyData.id, 32 )
            net.SendToServer()

            mainMenu.awaitingReply = true
        end

        local nameLabel = vgui.Create( "DLabel", panel )
        nameLabel:SetFont( "RVR_StartMenuSmall" )
        nameLabel:SetTextColor( textColor )
        nameLabel:SetText( "[" .. partyData.tag .. "] " .. partyData.name )

        local ownerLabel = vgui.Create( "DLabel", panel )
        ownerLabel:SetFont( "RVR_StartMenuSmall" )
        ownerLabel:SetTextColor( textColor )
        ownerLabel:SetText( partyData.owner:Nick() )

        local countLabel = vgui.Create( "DLabel", panel )
        countLabel:SetFont( "RVR_StartMenuSmall" )
        countLabel:SetTextColor( textColor )
        countLabel:SetText( #partyData.members .. "/" .. GAMEMODE.Config.Party.MAX_PLAYERS )

        local joinModeLabel = vgui.Create( "DLabel", panel )
        joinModeLabel:SetFont( "RVR_StartMenuSmall" )
        joinModeLabel:SetTextColor( textColor )
        local joinModeStrs = {
            [0] = "PUBLIC",
            [1] = "FRIENDS",
            [2] = "PRIVATE"
        }
        joinModeLabel:SetText( joinModeStrs[partyData.joinMode] )

        function panel:PerformLayout()
            local _w, _h = self:GetSize()

            nameLabel:SetPos( _w * 0.006, 0 )
            nameLabel:SetSize( _w * 0.39, _h )

            ownerLabel:SetPos( _w * 0.408, 0 )
            ownerLabel:SetSize( _w * 0.3, _h )

            countLabel:SetPos( _w * 0.75, 0 )
            countLabel:SetSize( _w * 0.04, _h )

            joinModeLabel:SetPos( _w * 0.885, 0 )
            joinModeLabel:SetSize( _w * 0.115, _h )
        end
    end
end

function mainMenu.createPartyJoinMenu( pageNum )
    mainMenu.pageNum = pageNum or 1

    local partiesPerPage = 10
    local maxPages = math.ceil( table.Count( RVR.Party.parties ) / partiesPerPage )
    maxPages = math.max( maxPages, 1 )

    local container = mainMenu.container

    local headerTexts = { "Name:", "Owner:", "Players:", "Type:" }
    local headerPoses = { 0.065, 0.47, 0.775, 0.932 }

    local boxX, boxY = mainMenu.w * 0.07, mainMenu.h * 0.31
    local boxW = mainMenu.w * 0.86
    local boxH = boxW * joinPartyBg:Height() / joinPartyBg:Width()

    for k, text in pairs( headerTexts ) do
        local pos = headerPoses[k]

        local headerLabel = vgui.Create( "DLabel", container )
        headerLabel:SetFont( "RVR_StartMenuLabel" )
        headerLabel:SetTextColor( mainMenu.darkerYellow )
        headerLabel:SetText( text )
        headerLabel:SizeToContentsX()
        local x = boxX + 15 + ( boxW - 30 ) * pos
        local y = boxY - ScrH() * 0.03
        headerLabel:SetPos( x, y )

        function headerLabel:PerformLayout()
            local _w = self:GetWide()
            self:SetPos( x - _w * 0.5, y )
        end
    end

    local partyBox = vgui.Create( "DImage", container )
    partyBox:SetPos( boxX, boxY )
    partyBox:SetSize( boxW, boxH )
    partyBox:DockPadding( 10, 10, 10, 0 )
    partyBox:SetMouseInputEnabled( true )

    function partyBox:Paint( _w, _h )
        surface.SetMaterial( joinPartyBg )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    local leftBtn = vgui.Create( "DButton", container )
    leftBtn:SetText( "" )
    leftBtn:SetSize( 100, 100 )
    leftBtn:SetPos( boxX, boxY + boxH - 10 )
    leftBtn:SetVisible( mainMenu.pageNum > 1 )

    function leftBtn:Paint( _w, _h )
        surface.SetMaterial( joinPartyArrow )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    function leftBtn:DoClick()
        mainMenu.setMenuPage( mainMenu.MENU_JOIN, math.max( mainMenu.pageNum - 1, 1 ) )
    end

    if maxPages > 1 then
        local pageCounter = vgui.Create( "DLabel", container )
        pageCounter:SetFont( "RVR_StartMenuButton" )
        pageCounter:SetTextColor( mainMenu.darkBrown )
        pageCounter:SetText( mainMenu.pageNum .. "/" .. maxPages )
        pageCounter:SizeToContents()

        function pageCounter:PerformLayout()
            local _w, _h = self:GetSize()
            local _x, _y = mainMenu.w * 0.5, boxY + boxH + 45

            self:SetPos( _x - _w * 0.5, _y - _h * 0.5 )
        end
    end

    local rightBtn = vgui.Create( "DButton", container )
    rightBtn:SetText( "" )
    rightBtn:SetSize( 100, 100 )
    rightBtn:SetPos( boxX + boxW - 100, boxY + boxH - 10 )
    rightBtn:SetVisible( mainMenu.pageNum < maxPages )

    function rightBtn:Paint( _w, _h )
        surface.SetMaterial( joinPartyArrow )
        surface.DrawTexturedRectUV( 0, 0, _w, _h, 1, 0, 0, 1 )
    end

    function rightBtn:DoClick()
        mainMenu.setMenuPage( mainMenu.MENU_JOIN, math.min( mainMenu.pageNum + 1, maxPages ) )
    end

    local parties = {}
    local startingPartyIndex = ( ( mainMenu.pageNum - 1 ) * partiesPerPage ) + 1
    local keys = table.GetKeys( RVR.Party.parties )
    for k = startingPartyIndex, startingPartyIndex + partiesPerPage - 1 do
        local key = keys[k]
        if not key then break end

        table.insert( parties, RVR.Party.parties[key] )
    end

    mainMenu.fillPartiesList( partyBox, parties )

    mainMenu.createNormalButton( "BACK", 50, mainMenu.h - 40 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        if mainMenu.awaitingReply then return end
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )
end
