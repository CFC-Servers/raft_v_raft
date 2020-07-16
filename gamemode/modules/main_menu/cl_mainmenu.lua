RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

local yellow = Color( 188, 162, 105 )
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

local w = ScrW() * 0.6
local firstBg = backgrounds[mainMenu.MENU_START]
local h = w * firstBg:Height() / firstBg:Width()

local imagePaths = file.Find( "materials/rvr/backgrounds/mainmenu_images/*.png", "GAME" )
local imageMats = {}
for k, imagePath in pairs( imagePaths ) do
    imageMats[k] = Material( "rvr/backgrounds/mainmenu_images/" .. imagePath )
end
local imageTime = 5

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

function mainMenu.setMenuPage( page )
    if not mainMenu.frame then return end

    mainMenu.frame.backgroundMat = backgrounds[page]
    mainMenu.container:Clear()
    mainMenu.container.menuButtons = {}

    if page == mainMenu.MENU_START then
        mainMenu.createStartMenu()
    elseif page == mainMenu.MENU_CREATE then
        mainMenu.createPartyCreateMenu()
    end
end

function mainMenu.createStartMenuButton( text, action )
    local container = mainMenu.container

    local x = w * 0.7
    local y = h * 0.5 + #container.menuButtons * ScrH() * 0.07

    local button = vgui.Create( "DButton", container )
    button:SetFont( "RVR_StartMenuButton" )
    button:SetText( text )
    button:SetTextColor( yellow )
    button:SetPos( x, y )
    button:SizeToContentsX()
    button:SetTall( ScrH() * 0.04 ) -- This font is really tall for some reason, this removes some extra whitespace
    button.DoClick = action

    function button:Paint( _w, _h )
        local mouseX, mouseY = input.GetCursorPos()
        local selfX, selfY = self:LocalToScreen( 0, 0 )

        if mouseX < selfX or mouseX > selfX + _w then return end
        if mouseY < selfY or mouseY > selfY + _h then return end

        surface.SetDrawColor( yellow )
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

            local offset = ( adjustedProg - 1 ) * _w
            surface.SetMaterial( self.nextImagePath )
            surface.DrawTexturedRect( offset, 0, _w, _h )

            surface.SetMaterial( self.imagePath )
            surface.DrawTexturedRect( offset + _w, 0, _w, _h )
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

        self:SetTextColor( lerpCol( darkBrown, yellow, button.hoverProg ) )
    end

    function button:Paint() end
end

function mainMenu.createTextEntry( text, x, y, entryW, maxLength, tooltip )
    local container = mainMenu.container

    local label = vgui.Create( "DLabel", container )
    label:SetFont( "RVR_StartMenuLabel" )
    label:SetText( text )
    label:SetTextColor( yellow )
    label:SizeToContentsX()
    label:SetTall( ScrH() * 0.04 )
    label:SetPos( x, y - ScrH() * 0.04 - 5 )
    label:SetMouseInputEnabled( true )
    if tooltip then label:SetTooltip( tooltip ) end

    local textEntry = vgui.Create( "DTextEntry", container )
    textEntry:SetFont( "RVR_StartMenuTextEntry" )
    textEntry:SetPos( x + 10, y )
    textEntry:SetSize( entryW, ScrH() * 0.04 )
    if tooltip then textEntry:SetTooltip( tooltip ) end

    function textEntry:Paint( _w, _h )
        DisableClipping( true )

        surface.SetDrawColor( 255, 255, 255 )
        surface.SetMaterial( textEntryBg )
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
    end

    return textEntry
end

function mainMenu.createPartyCreateMenu()
    mainMenu.createTextEntry( "PARTY NAME:", 100, h * 0.32, w - 200, GAMEMODE.Config.Party.MAX_PARTY_NAME_LENGTH )
    mainMenu.createTextEntry( "PARTY TAG:", 100, h * 0.45, 120, 4,
        "Tags are 4 characters prefixed to all members names in chat and (eventually) scoreboard." )

    mainMenu.createNormalButton( "BACK", 50, h - 40 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )

    mainMenu.createNormalButton( "CREATE", w - 50, h - 40 - ScrH() * 0.04, TEXT_ALIGN_RIGHT, function() end )


end
