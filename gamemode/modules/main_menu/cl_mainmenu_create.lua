RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

local textEntryBg = Material( "rvr/backgrounds/mainmenu_textbackground.png" )
local textEntryBgShort = Material( "rvr/backgrounds/mainmenu_textbackground_short.png" )

mainMenu.backgrounds = mainMenu.backgrounds or {}
mainMenu.backgrounds[mainMenu.MENU_CREATE] = Material( "rvr/backgrounds/mainmenu_create.png" )

function mainMenu.createEntry( data )
    data.action = function( val )
        data.tab[data.name] = val
    end

    local fontHeight = ScrH() * 0.04
    local defaultEntrySpacingMult = 0.13

    local text = data.text
    local entryW = data.entryWidth
    local tooltip = data.tooltip
    local entryClass = data.entryType
    local entryH = data.entryHeight or fontHeight

    local x = data.x or 100
    local y = data.y
    if not y then
        mainMenu.entryY = mainMenu.entryY + defaultEntrySpacingMult * mainMenu.h
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
    label:SetTextColor( mainMenu.darkerYellow )
    label:SizeToContentsX()
    label:SetTall( fontHeight )
    label:SetPos( x, y - fontHeight - headerSpacing )
    label:SetMouseInputEnabled( true )
    if tooltip then
        label:SetTooltip( tooltip )
    end

    data.label = label

    local errorLabel = mainMenu.createErrorLabel( data.name, 0, 0 )

    function errorLabel:PerformLayout()
        local _w = label:GetWide()
        local _x, _y = label:GetPos()
        self:SetPos( _x + _w + 20, _y )
    end

    local entry = vgui.Create( entryClass, container )
    entry:SetPos( x + 10, y )
    entry:SetSize( entryW, entryH )
    if tooltip then
        entry:SetTooltip( tooltip )
    end

    return entry
end

function mainMenu.createErrorLabel( name, x, y, centered )
    local errLabelDisplayTime = 3

    local errorLabel = vgui.Create( "DLabel", mainMenu.container )
    errorLabel:SetTextColor( Color( 255, 0, 0, 0 ) )
    errorLabel:SetFont( "RVR_StartMenuSmall" )
    errorLabel:SetText( "" )
    errorLabel:SetTall( fontHeight )
    errorLabel:SetPos( x, y )
    errorLabel.animProg = 0

    function errorLabel:SetError( err )
        self:SetText( err )
        self:SizeToContentsX()
        self.animProg = errLabelDisplayTime + 1 -- 1 for duration of fade animation
    end

    function errorLabel:Think()
        if self.animProg > 0 then
            self.animProg = math.max( 0, self.animProg - FrameTime() )
        end

        local alpha = math.Clamp( self.animProg, 0, 1 ) * 255
        self:SetTextColor( Color( 255, 0, 0, alpha ) )
    end

    if centered then
        function errorLabel:PerformLayout()
            local _w = self:GetWide()
            local _, _y = self:GetPos()
            self:SetPos( x - _w * 0.5, _y )
        end
    end

    mainMenu.errorLabels[name] = errorLabel

    return errorLabel
end

function mainMenu.createTextEntry( data )
    data.entryType = "DTextEntry"
    local textEntry = mainMenu.createEntry( data )
    local maxLength = data.maxLength

    textEntry:SetFont( "RVR_StartMenuTextEntry" )
    textEntry:SetTextColor( mainMenu.darkBrown )

    local extraX, extraY = 10, 5

    function textEntry:Paint( _w, _h )
        DisableClipping( true )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( data.short and textEntryBgShort or textEntryBg )
        surface.DrawTexturedRect( -extraX, -extraY, _w + extraX * 2, _h + extraY * 5 )

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
            self:SetTextColor( v and mainMenu.darkerYellow or mainMenu.darkBrown )

            if v then
                data.action( self.option )
            end
        end

        function btn:Paint( _w, _h )
            local bgCol = self.selected and mainMenu.darkBrown or mainMenu.darkerYellow
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
    mainMenu.entryY = mainMenu.h * 0.19

    local partyData = {}

    mainMenu.createTextEntry{
        text = "PARTY NAME:",
        entryWidth = mainMenu.w - 200,
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
        entryWidth = mainMenu.w * 0.34,
        entryHeight = mainMenu.h * 0.265,
        defaultColor = HSVToColor( math.random( 0, 360 ), 1, 1 ),
        name = "color",
        tab = partyData,
        headerSpacing = 15
    }

    mainMenu.createRadioMenuEntry{
        text = "SELECT ONE:",
        x = mainMenu.w * 0.5,
        y = mainMenu.entryY,
        entryWidth = mainMenu.w * 0.4,
        entryHeight = mainMenu.h * 0.29,
        options = { "PUBLIC", "STEAM FRIENDS", "PRIVATE" },
        name = "joinModeStr",
        tab = partyData
    }

    mainMenu.createErrorLabel( "generic", mainMenu.w * 0.5, mainMenu.h * 0.94, true )

    mainMenu.awaitingReply = false

    mainMenu.createNormalButton( "BACK", 50, mainMenu.h - 40 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        if mainMenu.awaitingReply then return end
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )

    mainMenu.createNormalButton( "CREATE", mainMenu.w - 50, mainMenu.h - 40 - ScrH() * 0.04, TEXT_ALIGN_RIGHT, function()
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

        RVR.Party.tryCreateParty( partyData.name, partyData.tag, color, joinMode, function( success, err, errType )
            if not mainMenu.awaitingReply then return end
            if not mainMenu.frame then return end

            if success then
                mainMenu.closeMenu()
                net.Start( "RVR_MainMenu_SpawnSelf" )
                net.SendToServer()
            else
                if errType == "name" or errType == "tag" then
                    mainMenu.errorLabels[errType]:SetError( "Already taken" )
                else
                    mainMenu.errorLabels.generic:SetError( err )
                end

                mainMenu.awaitingReply = false
            end
        end )

        mainMenu.awaitingReply = true
    end )
end
