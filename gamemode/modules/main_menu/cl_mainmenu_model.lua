RVR.MainMenu = RVR.MainMenu or {}
local mainMenu = RVR.MainMenu

mainMenu.backgrounds = mainMenu.backgrounds or {}
mainMenu.backgrounds[mainMenu.MENU_MODEL] = Material( "rvr/backgrounds/mainmenu_model.png" )

local scrollerBackgroundMat = Material( "rvr/backgrounds/mainmenu_characterselect_background.png" )

-- Makes the scrollbar look pretty
local function formatScrollbar( bar )
    bar:SetHideButtons( true )

    function bar:Paint( w, h )
        local offsetX = math.Round( w * 0.25 )
        local offsetY = 10
        draw.RoundedBox( 4, offsetX, offsetY, w - offsetX * 2, h - offsetY * 2, Color( 89, 55, 30 ) )
    end

    function bar.btnGrip:Paint( w, h )
        draw.RoundedBox( 10, 0, 0, w, h, Color( 188, 162, 105 ) )
    end

    -- Makes the scrollbar always show
    function bar:SetUp( barSize, canvasSize )
        self.BarSize = barSize
        self.CanvasSize = math.max( canvasSize - barSize, 0.01 )

        self:SetEnabled( true )

        self:InvalidateLayout()
    end
end

function mainMenu.createModelMenu()
    local modelPanel = vgui.Create( "DModelPanel", mainMenu.container )
    modelPanel:SetPos( mainMenu.w * 0.077, mainMenu.h * 0.225 )
    modelPanel:SetSize( mainMenu.w * 0.347, mainMenu.h * 0.66 )
    modelPanel:SetModel( LocalPlayer():GetModel() )
    modelPanel:SetMouseInputEnabled( false )

    -- Go far away and zoom in, to give less of a "fish-eye" effect
    modelPanel:SetCamPos( Vector( 185, 0, 33 ) )
    modelPanel:SetLookAng( Angle( 0, 180, 0 ) )
    modelPanel:SetFOV( 20 )
    modelPanel:SetCursor( "none" )
    modelPanel.startTime = RealTime()

    function modelPanel:LayoutEntity( ent )
        if ( self.bAnimated ) then
            self:RunAnimation()
        end

        local t = RealTime() - self.startTime
        ent:SetAngles( Angle( 0, t * 10 % 360, 0 ) )
    end

    local scrollerContainer = vgui.Create( "DPanel", mainMenu.container )
    scrollerContainer:SetPos( mainMenu.w * 0.57, mainMenu.h * 0.223 )
    local scrollerWidth = mainMenu.w * 0.39
    scrollerContainer:SetSize( scrollerWidth, mainMenu.h * 0.667 )

    function scrollerContainer:Paint( w, h )
        surface.SetMaterial( scrollerBackgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, 0.9 * w, h )
    end

    local scrollerMargin = 10

    local scroller = vgui.Create( "DScrollPanel", scrollerContainer )
    scroller:Dock( FILL )
    scroller:DockMargin( scrollerMargin, scrollerMargin, scrollerMargin, scrollerMargin )

    formatScrollbar( scroller:GetVBar() )

    local spawnIconPerRow = 3
    local spacingMult = 0.9
    local gridSize = ( ( scrollerWidth - scrollerMargin * 2 ) * 0.9 ) / spawnIconPerRow
    local spawnIconSize = gridSize * spacingMult

    local spacing = gridSize * ( 1 - spacingMult ) * 0.5

    local idx = 0
    local spawnIcons = {}
    for _, mdl in pairs( GAMEMODE.Config.Generic.PLAYER_MODELS ) do
        local selected = mdl == LocalPlayer():GetModel()

        local gridX = idx % spawnIconPerRow
        local gridY = math.floor( idx / spawnIconPerRow )

        local spawnIconContainer = vgui.Create( "DImage", scroller )
        spawnIconContainer:SetPos( gridX * gridSize + spacing, gridY * gridSize + spacing )
        spawnIconContainer:SetSize( spawnIconSize, spawnIconSize )
        spawnIconContainer:SetMouseInputEnabled( true )
        spawnIconContainer:SetImage( "materials/rvr/backgrounds/dark_slot_background.png" )
        spawnIconContainer:SetCursor( "hand" )

        function spawnIconContainer:OnMousePressed( btn )
            if btn ~= MOUSE_LEFT then return end
            self:SetSelected( true )
        end

        local spawnIcon = vgui.Create( "SpawnIcon", spawnIconContainer )
        spawnIcon:SetSize( spawnIconSize - 24, spawnIconSize - 12 )
        spawnIcon:SetPos( 12, 5 )
        spawnIcon:SetModel( mdl )
        spawnIcon:SetMouseInputEnabled( false )

        TEST_ICON_THING = spawnIcon

        function spawnIconContainer:SetSelected( v )
            self.selected = v

            local color = Color( 255, 255, 255 )

            if v then
                color = Color( 150, 150, 150 )
                overlayOpacity = 50
                for _, icon in pairs( spawnIcons ) do
                    if icon ~= self then
                        icon:SetSelected( false )
                    end
                end

                modelPanel:SetModel( mdl )
            end

            self:SetImageColor( color )
        end

        spawnIconContainer:SetSelected( selected )

        table.insert( spawnIcons, spawnIconContainer )
        idx = idx + 1
    end

    mainMenu.createNormalButton( "BACK", 50, mainMenu.h - 30 - ScrH() * 0.04, TEXT_ALIGN_LEFT, function()
        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )

    mainMenu.createNormalButton( "SAVE", mainMenu.w - 50, mainMenu.h - 30 - ScrH() * 0.04, TEXT_ALIGN_RIGHT, function()
        local model = modelPanel:GetModel()

        net.Start( "RVR_MainMenu_SetModel" )
            net.WriteString( model )
        net.SendToServer()

        mainMenu.setMenuPage( mainMenu.MENU_START )
    end )
end
