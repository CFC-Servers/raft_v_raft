RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

mainMenu.darkerYellow = Color( 172, 138, 90 )
mainMenu.darkBrown = Color( 63, 43, 0 )

local camPos = Vector( 0, 0, 300 )
local camAng = Angle( 12, 135, 0 )

mainMenu.MENU_START = 0
mainMenu.MENU_CREATE = 1
mainMenu.MENU_JOIN = 2
mainMenu.MENU_MODEL = 3

mainMenu.backgrounds = mainMenu.backgrounds or {}

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
    if mainMenu.frame or mainMenu.toShow then return false end
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

hook.Add( "RVR_PlayerDeath", "RVR_ShowMenu", function( ply )
    if ply ~= LocalPlayer() then return end
    if ply:GetPartyID() then return end
    mainMenu.showIn( 1 )
end )

hook.Add( "Initialize", "RVR_ShowMenu", function()
    mainMenu.createMenu()
end )

function mainMenu.showIn( delay )
    mainMenu.toShow = true
    timer.Simple( delay, function()
        mainMenu.createMenu()
        mainMenu.toShow = false
    end )
end

function mainMenu.createMenu()
    if mainMenu.frame then
        mainMenu.frame:Remove()
        mainMenu.frame = nil
    end

    if not mainMenu.w then
        mainMenu.w = ScrW() * 0.6
        local firstBg = mainMenu.backgrounds[mainMenu.MENU_START]
        mainMenu.h = mainMenu.w * firstBg:Height() / firstBg:Width()
    end

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:SetSize( mainMenu.w, mainMenu.h )
    frame:CenterHorizontal()
    local x = frame:GetPos()
    frame:SetPos( x, 0.3 * ( ScrH() - mainMenu.h ) )
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

    mainMenu.frame.backgroundMat = mainMenu.backgrounds[page]
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
    elseif page == mainMenu.MENU_MODEL then
        mainMenu.createModelMenu( ... )
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
    button:SetTextColor( mainMenu.darkBrown )
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

        self:SetTextColor( lerpCol( mainMenu.darkBrown, mainMenu.darkerYellow, button.hoverProg ) )
    end

    function button:Paint() end
end
