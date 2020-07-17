RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

local imagePaths = file.Find( "materials/rvr/backgrounds/mainmenu_images/*.png", "GAME" )
local imageMats = {}
for k, imagePath in pairs( imagePaths ) do
    imageMats[k] = Material( "rvr/backgrounds/mainmenu_images/" .. imagePath )
end
local imageTime = 5

mainMenu.errorLabels = {}

mainMenu.backgrounds = mainMenu.backgrounds or {}
mainMenu.backgrounds[mainMenu.MENU_START] = Material( "rvr/backgrounds/mainmenu_start.png" )

function mainMenu.createStartMenuButton( text, action )
    local container = mainMenu.container

    local x = mainMenu.w * 0.69
    local y = mainMenu.h * 0.5 + #container.menuButtons * ScrH() * 0.07

    local button = vgui.Create( "DButton", container )
    button:SetFont( "RVR_StartMenuButton" )
    button:SetText( text )
    button:SetTextColor( mainMenu.darkerYellow )
    button:SetPos( x, y )
    button:SizeToContentsX()
    button:SetTall( ScrH() * 0.04 ) -- This font is really tall for some reason, this removes some extra whitespace
    button.DoClick = action

    function button:Paint( _w, _h )
        local mouseX, mouseY = input.GetCursorPos()
        local selfX, selfY = self:LocalToScreen( 0, 0 )

        if mouseX < selfX or mouseX > selfX + _w then return end
        if mouseY < selfY or mouseY > selfY + _h then return end

        surface.SetDrawColor( mainMenu.darkerYellow )
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

    mainMenu.createStartMenuButton( "CUSTOMIZE", function()
        mainMenu.setMenuPage( mainMenu.MENU_MODEL )
    end )

    mainMenu.createStartMenuButton( "LEAVE GAME", function()
        RunConsoleCommand( "disconnect" )
    end )

    local imageContainer = vgui.Create( "DPanel", mainMenu.container )
    imageContainer:SetPos( mainMenu.w * 0.03, mainMenu.h * 0.035 )
    imageContainer:SetSize( mainMenu.w * 0.6, mainMenu.h * 0.935 )

    function imageContainer:Paint( _w, _h )
        draw.RoundedBox( 5, 0, 0, _w, _h, mainMenu.darkBrown )
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
