RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

local darkerYellow = Color( 172, 138, 90 )
local darkBrown = Color( 63, 43, 0 )

local camPos = Vector( 0, 0, 300 )
local camAng = Angle( 12, 135, 0 )

mainMenu.MENU_START = 0
mainMenu.MENU_CREATE = 1
mainMenu.MENU_JOIN = 2
mainMenu.MENU_MODEL = 3

local backgrounds = {
    [mainMenu.MENU_START] = Material( "rvr/backgrounds/mainmenu_start.png" ),
    [mainMenu.MENU_CREATE] = Material( "rvr/backgrounds/mainmenu_create.png" ),
    [mainMenu.MENU_JOIN] = Material( "rvr/backgrounds/mainmenu_join.png" ),
    [mainMenu.MENU_MODEL] = Material( "rvr/backgrounds/mainmenu_model.png" ),
}

local textEntryBg = Material( "rvr/backgrounds/mainmenu_textbackground.png" )
local textEntryBgShort = Material( "rvr/backgrounds/mainmenu_textbackground_short.png" )
local joinPartyBg = Material( "rvr/backgrounds/mainmenu_joinpartybox.png" )
local joinPartyArrow = Material( "rvr/icons/mainmenu_joinpartyarrow.png" )

local w = ScrW() * 0.6
local firstBg = backgrounds[mainMenu.MENU_START]
local h = w * firstBg:Height() / firstBg:Width()

local imagePaths = file.Find( "materials/rvr/backgrounds/mainmenu_images/*.png", "GAME" )
local imageMats = {}
for k, imagePath in pairs( imagePaths ) do
    imageMats[k] = Material( "rvr/backgrounds/mainmenu_images/" .. imagePath )
end
local imageTime = 5

mainMenu.errorLabels = {}

surface.CreateFont( "RVR_StartMenuButton", {
    font = "Bungee Regular",
    size = ScrH() * 0.09,
    weight = 700,
} )

surface.CreateFont( "RVR_StartMenuLabel", {
    font = "Bungee Regular",
    size = ScrH() * 0.07,
    weight = 700,
} )

surface.CreateFont( "RVR_StartMenuSmall", {
    font = "Bungee Regular",
    size = ScrH() * 0.05,
    weight = 700,
} )

surface.CreateFont( "RVR_StartMenuTextEntry", {
    font = "Roboto",
    size = ScrH() * 0.04,
    weight = 700,
} )

hook.Add( "HUDShouldDraw", "RVR_MainMenu_HideHud", function( hudType )
    if hudType == "CHudGMod" then return end
    if mainMenu.frame then return false end
end )

hook.Add( "HUDPaintBackground", "RVR_MainMenu", function()
    if not mainMenu.frame then return end
    local _w, _h = ScrW(), ScrH()

    render.RenderView( {
        origin = camPos,
        angles = camAng,
        x = 0, y = 0,
        w = _w, h = _h,
    } )
end )

function mainMenu.createMenu()
    if mainMenu.frame then
        mainMenu.frame:Remove()
        mainMenu.frame = nil
    end

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:SetSize( w, h )
    frame:CenterHorizontal()
    local x = frame:GetPos()
    frame:SetPos( x, 0.3 * ( ScrH() - h ) )
    frame:SetDraggable( false )
    frame:MakePopup()

    function frame:Paint( _w, _h )
        surface.SetMaterial( self.backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    mainMenu.frame = frame

    local container = vgui.Create( "DPanel", frame )
    container:SetPos( 0, 0 )
    container.Paint = nil

    function container:PerformLayout()
        self:SetSize( self:GetParent():GetSize() )
    end

    mainMenu.container = container

    mainMenu.setMenuPage( mainMenu.MENU_START )
end

function mainMenu.closeMenu()
    if mainMenu.frame then
        mainMenu.frame:Remove()
        mainMenu.frame = nil
    end
end

function mainMenu.setMenuPage( page, ... )
    if not mainMenu.frame then return end

    mainMenu.frame.backgroundMat = backgrounds[page]
    mainMenu.container:Clear()
    mainMenu.container.menuButtons = {}

    if mainMenu.page ~= mainMenu.MENU_JOIN then
        mainMenu.pageNum = nil
    end

    mainMenu.page = page

    if page == mainMenu.MENU_START then
        mainMenu.createStartMenu( ... )
    elseif page == mainMenu.MENU_CREATE then
        mainMenu.createPartyCreateMenu( ... )
    elseif page == mainMenu.MENU_JOIN then
        mainMenu.createPartyJoinMenu( ... )
    end
end

function mainMenu.createStartMenuButton( text, action )
    local container = mainMenu.container

    local x = w * 0.7
    local y = h * 0.5 + #container.menuButtons * ScrH() * 0.07

    local button = vgui.Create( "DButton", container )
    button:SetFont( "RVR_StartMenuButton" )
    button:SetText( text )
    button:SetTextColor( darkerYellow )
    button:SetPos( x, y )
    button:SizeToContentsX()
    button:SetTall( ScrH() * 0.04 ) -- This font is really tall for some reason, this removes some extra whitespace
    button.DoClick = action

    function button:Paint( _w, _h )
        local mouseX, mouseY = input.GetCursorPos()
        local selfX, selfY = self:LocalToScreen( 0, 0 )

        if mouseX < selfX or mouseX > selfX + _w then return end
        if mouseY < selfY or mouseY > selfY + _h then return end

        surface.SetDrawColor( darkerYellow )
        surface.DrawRect( 0, _h - 1, _w, 1 )

        -- Draws a lil dot to the left
        DisableClipping( true )

        local dotSize = 7
        surface.DrawRect( -20, ( _h - dotSize ) * 0.5, dotSize, dotSize )

        DisableClipping( false )
    end

    table.insert( container.menuButtons, button )
end

function mainMenu.createStartMenu()
    mainMenu.createStartMenuButton( "CREATE PARTY", function()
        mainMenu.setMenuPage( mainMenu.MENU_CREATE )
    end )

    mainMenu.createStartMenuButton( "JOIN PARTY", function()
        mainMenu.setMenuPage( mainMenu.MENU_JOIN )
    end )

    mainMenu.createStartMenuButton( "LEAVE GAME", function()
        RunConsoleCommand( "disconnect" )
    end )

    local imageContainer = vgui.Create( "DPanel", mainMenu.container )
    imageContainer:SetPos( w * 0.03, h * 0.035 )
    imageContainer:SetSize( w * 0.6, h * 0.935 )

    function imageContainer:Paint( _w, _h )
        draw.RoundedBox( 5, 0, 0, _w, _h, darkBrown )
    end

    local image = vgui.Create( "DPanel", imageContainer )
    image:Dock( FILL )
    image:DockMargin( 5, 5, 5, 5 )
    image.imagePath = imageMats[1]
    image.lastSwitch = CurTime()
    image.imageIndex = 1

    function image:SwitchImage( path )
        self.nextImagePath = path
        self.nextImageProg = 0
    end

    function image:Think()
        local curTime = CurTime()
        if curTime - self.lastSwitch > imageTime then
            self.lastSwitch = curTime
            self.imageIndex = self.imageIndex + 1
            if self.imageIndex > #imageMats then
                self.imageIndex = 1
            end

            self:SwitchImage( imageMats[self.imageIndex] )
        end
    end

    function image:Paint( _w, _h )
        surface.SetDrawColor( 255, 255, 255 )

        if self.nextImagePath then
            local dt = FrameTime()
            self.nextImageProg = math.Clamp( self.nextImageProg + dt, 0, 1 )
            if self.nextImageProg == 1 then
                self.imagePath = self.nextImagePath
                self.nextImagePath = nil
            end
        end

        if self.nextImagePath then
            local adjustedProg = ( 1 - math.cos( self.nextImageProg * math.pi ) ) * 0.5;

            local offset = ( 1 - adjustedProg ) * _w
            surface.SetMaterial( self.nextImagePath )
            surface.DrawTexturedRect( offset, 0, _w, _h )

            surface.SetMaterial( self.imagePath )
            surface.DrawTexturedRect( offset - _w, 0, _w, _h )
        else
            surface.SetMaterial( self.imagePath )
            surface.DrawTexturedRect( 0, 0, _w, _h )
        end
    end
end

local function lerpCol( a, b, l )
    return Color( Lerp( l, a.r, b.r ), Lerp( l, a.g, b.g ), Lerp( l, a.b, b.b ), Lerp( l, a.a, b.a ) )
end

function mainMenu.createNormalButton( text, x, y, alignment, action )
    local container = mainMenu.container

    local button = vgui.Create( "DButton", container )
    button:SetFont( "RVR_StartMenuButton" )
    button:SetText( text )
    button:SetTextColor( darkBrown )
    button:SizeToContentsX()
    button:SetTall( ScrH() * 0.04 ) -- This font is really tall for some reason, this removes some extra whitespace
    button.DoClick = action
    button.hoverProg = 0

    function button:PerformLayout()
        if alignment == TEXT_ALIGN_RIGHT then
            self:SetPos( x - self:GetWide(), y )
        else
            self:SetPos( x, y )
        end
    end

    local animSpeed = 10
    function button:Think()
        local isHovered = self:IsHovered()
        if isHovered and button.hoverProg < 1 then
            button.hoverProg = math.min( button.hoverProg + FrameTime() * animSpeed, 1 )
        elseif not isHovered and button.hoverProg > 0 then
            button.hoverProg = math.max( button.hoverProg - FrameTime() * animSpeed, 0 )
        end

        self:SetTextColor( lerpCol( darkBrown, darkerYellow, button.hoverProg ) )
    end

    function button:Paint() end
end

function mainMenu.createEntry( data )
    data.action = function( val )
        data.tab[data.name] = val
    end

    local text = data.text
    local entryW = data.entryWidth
    local tooltip = data.tooltip
    local entryClass = data.entryType
    local entryH = data.entryHeight or ScrH() * 0.04

    local x = data.x or 100
    local y = data.y
    if not y then
        mainMenu.entryY = mainMenu.entryY + 0.13 * h
        y = mainMenu.entryY
    end

    local container = mainMenu.container

    local headerSpacing = 5
    if data.headerSpacing then
        headerSpacing = data.headerSpacing
        y = y + headerSpacing - 5
    end

    local label = vgui.Create( "DLabel", container )
    label:SetFont( "RVR_StartMenuLabel" )
    label:SetText( text )
    label:SetTextColor( darkerYellow )
    label:SizeToContentsX()
    label:SetTall( ScrH() * 0.04 )
    label:SetPos( x, y - ScrH() * 0.04 - headerSpacing )
    label:SetMouseInputEnabled( true )
    if tooltip then label:SetTooltip( tooltip ) end

    data.label = label

    local errorLabel = vgui.Create( "DLabel", container )
    errorLabel:SetTextColor( Color( 255, 0, 0, 0 ) )
    errorLabel:SetFont( "RVR_StartMenuSmall" )
    errorLabel:SetText( "" )
    errorLabel:SetTall( ScrH() * 0.04 )
    errorLabel.animProg = 0

    function errorLabel:SetError( err )
        self:SetText( err )
        self:SizeToContentsX()
        self.animProg = 4
    end

    function errorLabel:Think()
        if self.animProg > 0 then
            self.animProg = math.max( 0, self.animProg - FrameTime() )
        end

        local alpha = math.Clamp( self.animProg, 0, 1 ) * 255
        self:SetTextColor( Color( 255, 0, 0, alpha ) )
    end

    function errorLabel:PerformLayout()
        local _w = label:GetWide()
        local _x, _y = label:GetPos()
        self:SetPos( _x + _w + 50, _y )
    end

    mainMenu.errorLabels[data.name] = errorLabel

    local entry = vgui.Create( entryClass, container )
    entry:SetPos( x + 10, y )
    entry:SetSize( entryW, entryH )
    if tooltip then entry:SetTooltip( tooltip ) end

    return entry
end

function mainMenu.createTextEntry( data )
    data.entryType = "DTextEntry"
    local textEntry = mainMenu.createEntry( data )
    local maxLength = data.maxLength

    textEntry:SetFont( "RVR_StartMenuTextEntry" )
    textEntry:SetTextColor( darkBrown )

    function textEntry:Paint( _w, _h )
        DisableClipping( true )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( data.short and textEntryBgShort or textEntryBg )
        surface.DrawTexturedRect( -10, -5, _w + 20, _h + 10 )

        DisableClipping( false )

        self:DrawTextEntryText( self:GetTextColor(), self:GetHighlightColor(), self:GetCursorColor() )
    end

    function textEntry:OnTextChanged()
        local curText = self:GetText()
        if curText and #curText > maxLength then
            self:SetText( string.Left( curText, maxLength ) )
            self:SetCaretPos( maxLength )
            surface.PlaySound( "resource/warning.wav" )
        end

        data.action( curText )
    end

    data.action( "" )

    return textEntry
end

function mainMenu.createColorEntry( data )
    data.entryType = "DColorMixer"
    local picker = mainMenu.createEntry( data )
    picker:SetColor( data.defaultColor )
    picker:SetAlphaBar( false )
    picker:SetPalette( false )
    picker:SetWangs( false )

    function picker:Paint( _w, _h )
        DisableClipping( true )

        draw.RoundedBox( 6, -10, -10, _w + 20, _h + 20, Color( 158, 122, 74 ) )

        DisableClipping( false )
    end

    function picker:ValueChanged( col )
        data.action( col )
    end

    local preview = vgui.Create( "DPanel", mainMenu.container )
    preview:SetSize( 30, 30 )

    function preview:PerformLayout()
        local x, y = data.label:GetPos()
        local _w, _h = data.label:GetSize()
        self:SetPos( x + _w + 10, y + _h * 0.5 - 13 )
    end

    function preview:Paint( _w, _h )
        draw.RoundedBox( 10, 3, 3, _w - 6, _h - 6, picker:GetColor() )
    end

    data.action( data.defaultColor )
end

function mainMenu.createRadioMenuEntry( data )
    data.entryType = "DPanel"
    local panel = mainMenu.createEntry( data )
    panel.Paint = nil

    local spacing = 15

    local btns = {}
    for k, option in pairs( data.options ) do
        local last = k == #data.options

        local btn = vgui.Create( "DButton", panel )
        btn:SetFont( "RVR_StartMenuButton" )
        btn:SetText( option )
        btn:Dock( TOP )
        btn:DockMargin( 0, 0, 0, last and 0 or spacing )
        btn.option = option

        function btn:PerformLayout()
            local _h = panel:GetTall() + spacing
            _h = _h / #data.options - spacing
            self:SetTall( _h )
        end

        function btn:DoClick()
            for _, other in pairs( btns ) do
                if other ~= self then
                    other:SetSelected( false )
                end
            end

            self:SetSelected( true )
        end

        function btn:SetSelected( v )
            self.selected = v
            self:SetTextColor( v and darkerYellow or darkBrown )

            if v then
                data.action( self.option )
            end
        end

        function btn:Paint( _w, _h )
            local bgCol = self.selected and darkBrown or darkerYellow
            draw.RoundedBox( 10, 0, 0, _w, _h, bgCol )
        end

        btn:SetSelected( k == 1 )
        table.insert( btns, btn )
    end
end

local joinModeLookup = {
    ["PUBLIC"] = 0,
    ["STEAM FRIENDS"] = 1,
    ["PRIVATE"] = 2,
}

function mainMenu.createPartyCreateMenu()
    mainMenu.errorLabels = {}
    mainMenu.entryY = h * 0.19

    local partyData = {}

    mainMenu.createTextEntry{
        text = "PARTY NAME:",
        entryWidth = w - 200,
        maxLength = GAMEMODE.Config.Party.MAX_PARTY_NAME_LENGTH,
        name = "name",
        tab = partyData
    }

    mainMenu.createTextEntry{
        text = "PARTY TAG:",
        entryWidth = 120,
        maxLength = 4,
        short = true,
        tooltip = "Tags are 4 characters prefixed to all members names in chat and (eventually) scoreboard.",
        name = "tag",
        tab = partyData
    }

    mainMenu.createColorEntry{
        text = "PARTY COLOR:",
        entryWidth = w * 0.34,
        entryHeight = h * 0.265,
        defaultColor = HSVToColor( math.random( 0, 360 ), 1, 1 ),
        name = "color",
        tab = partyData,
        headerSpacing = 15
    }

    mainMenu.createRadioMenuEntry{
        text = "SELECT ONE:",
        x = w * 0.5,
        y = mainMenu.entryY,
        entryWidth = w * 0.4,
        entryHeight = h * 0.29,
        options = { "PUBLIC", "STEAM FRIENDS", "PRIVATE" },
        name = "joinModeStr",
        tab = partyData
    }

    mainMenu.awaitingReply = false

    mainMenu.createNormalButton( "BACK", 50, h - 40 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        if mainMenu.awaitingReply then return end
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )

    mainMenu.createNormalButton( "CREATE", w - 50, h - 40 - ScrH() * 0.04, TEXT_ALIGN_RIGHT, function()
        if mainMenu.awaitingReply then return end
        local joinMode = joinModeLookup[partyData.joinModeStr]
        -- Color picker returns color without meta table, this packs it back up
        local color = Color( partyData.color.r, partyData.color.g, partyData.color.b )

        local nameMinLen = GAMEMODE.Config.Party.MIN_PARTY_NAME_LENGTH
        local valid = true
        if #partyData.name < nameMinLen then
            mainMenu.errorLabels.name:SetError( "Name too short! Must be more than " .. nameMinLen .. " characters" )
            valid = false
        end

        if #partyData.tag ~= 4 then
            mainMenu.errorLabels.tag:SetError( "Tag must be 4 characters" )
            valid = false
        end

        if not valid then return end

        RVR.Party.tryCreateParty( partyData.name, partyData.tag, color, joinMode, function( success, err )
            if not mainMenu.awaitingReply then return end
            if not mainMenu.frame then return end

            if success then
                mainMenu.setMenuPage( mainMenu.MENU_MODEL )
            else
                -- TODO: show this data
                print( err )

                mainMenu.awaitingReply = false
            end
        end )

        mainMenu.awaitingReply = true
    end )
end

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

hook.Add( "RVR_Party_PartyChanged", "RVR_MainMenu_UpdateList", mainMenu.refreshJoinPartyList )

net.Receive( "RVR_Party_joinParty", function()
    if not mainMenu.awaitingReply then return end
    if not mainMenu.frame then return end

    local success = net.ReadBool()

    if success then
        mainMenu.setMenuPage( mainMenu.MENU_MODEL )
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
            textColor = canJoin and darkBrown or Color( 160, 0, 0 )
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
            countLabel:SetSize( w * 0.04, _h )

            joinModeLabel:SetPos( _w * 0.885, 0 )
            joinModeLabel:SetSize( w * 0.115, _h )
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

    local boxX, boxY = w * 0.07, h * 0.31
    local boxW = w * 0.86
    local boxH = boxW * joinPartyBg:Height() / joinPartyBg:Width()

    for k, text in pairs( headerTexts ) do
        local pos = headerPoses[k]

        local headerLabel = vgui.Create( "DLabel", container )
        headerLabel:SetFont( "RVR_StartMenuLabel" )
        headerLabel:SetTextColor( darkerYellow )
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
        pageCounter:SetTextColor( darkBrown )
        pageCounter:SetText( mainMenu.pageNum .. "/" .. maxPages )
        pageCounter:SizeToContents()

        function pageCounter:PerformLayout()
            local _w, _h = self:GetSize()
            local _x, _y = w * 0.5, boxY + boxH + 45

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

    mainMenu.createNormalButton( "BACK", 50, h - 40 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        if mainMenu.awaitingReply then return end
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )
end
