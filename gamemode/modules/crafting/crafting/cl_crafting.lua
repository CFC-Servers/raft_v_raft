local cft = RVR.Crafting
local backgroundMat = Material( "rvr/backgrounds/crafting_background.png" )
local categoriesBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categoriesbackground.png" )
local iconBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categorybackground.png" )
local yellow = Color( 188, 162, 105 )
local brown = Color( 91, 56, 34 )
local categoryMats = {}

-- Pre-loading category materials
for _, category in pairs( cft.Recipes ) do
    categoryMats[category.name] = Material( category.icon )
end

-- TODO: Move this to some sort of util file (same with def in inventory scroller)
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
    function bar:SetUp( _barsize_, _canvassize_ )
        self.BarSize = _barsize_
        self.CanvasSize = math.max( _canvassize_ - _barsize_, 0.01 )

        self:SetEnabled( true )

        self:InvalidateLayout()
    end
end


surface.CreateFont( "RVR_CraftingHeader", {
    font = "Bungee Regular",
    size = ScrH() * 0.1,
    weight = 700,
} )

function cft.openCraftingMenu( tier )
    if cft.openMenu then
        cft.closeCraftingMenu()
    end

    tier = tier or 1

    local w, h = ScrH() * 0.91, ScrH() * 0.7

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:ShowCloseButton( false )
    frame:SetSize( w, h )
    frame:CenterHorizontal()
    local x = frame:GetPos()
    frame:SetPos( x, 0.3 * ( ScrH() - h ) )
    frame:SetDraggable( false )
    frame:MakePopup()
    frame:SetDeleteOnClose( false )

    cft.openMenu = frame

    function frame:Paint( _w, _h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    function frame:OnClose()
        cft.closeCraftingMenu()
    end

    local closeButton = vgui.Create( "DImageButton", frame )
    closeButton:SetPos( w * 0.94, h * 0.03 )
    closeButton:SetSize( 30, 30 )
    closeButton:SetImage( "materials/rvr/icons/player_inventory_close.png" )
    function closeButton:DoClick()
        frame:Close()
    end

    local categoryScroller = vgui.Create( "DScrollPanel", frame )
    categoryScroller:GetVBar():SetWide( 0 )

    local left = w * 0.02
    local padding = w * 0.05
    local scrollerHeight = h - padding * 2
    local scrollerWidth = scrollerHeight * 0.185
    categoryScroller:SetPos( left + 1, padding )
    categoryScroller:SetSize( scrollerWidth - 2, scrollerHeight )
    categoryScroller:GetCanvas():InvalidateLayout( true )

    function categoryScroller:Paint( _w, _h )
        surface.SetMaterial( categoriesBackgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    local scrollerButtonMat = Material( "rvr/icons/craftingmenu_categoryscrollbutton.png" )

    local upButton = vgui.Create( "DImageButton", frame )
    upButton:SetPos( left, padding - w * 0.025 + 1 )
    upButton:SetSize( scrollerWidth, w * 0.025 )
    function upButton:Paint( _w, _h )
        surface.SetMaterial( scrollerButtonMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRectUV( 0, 0, _w, _h, 1, 1, 0, 0 )
    end

    local downButton = vgui.Create( "DImageButton", frame )
    downButton:SetPos( left, padding + scrollerHeight - 1 )
    downButton:SetSize( scrollerWidth, w * 0.025 )
    downButton:SetImage( "rvr/icons/craftingmenu_categoryscrollbutton.png" )

    function categoryScroller:Think()
        local change = ( downButton:IsDown() and 1 or 0 ) - ( upButton:IsDown() and 1 or 0 )
        if change == 0 then return end

        self:GetVBar():AddScroll( change * 0.05 )
    end

    local firstCat
    for _, category in ipairs( cft.Recipes ) do
        if category.minTier > tier then continue end
        firstCat = firstCat or category

        local categoryButton = vgui.Create( "DImageButton", categoryScroller )
        categoryButton:Dock( TOP )
        categoryButton:DockMargin( 10, 10, 10, 10 )
        categoryButton:InvalidateParent( true )
        categoryButton:SetTall( categoryButton:GetWide() )

        function categoryButton:DoClick()
            cft.setCategory( category )
        end

        function categoryButton:Paint( _w, _h )
            -- Background
            surface.SetMaterial( iconBackgroundMat )
            surface.SetDrawColor( Color( 255, 255, 255 ) )
            surface.DrawTexturedRect( 0, 0, _w, _h )

            -- Icon
            local margin = 5
            surface.SetMaterial( categoryMats[category.name] )
            surface.SetDrawColor( Color( 120, 100, 100 ) )
            surface.DrawTexturedRect( margin, margin, _w - ( margin * 2 ), _h - ( margin * 2 ) )
        end
    end

    local paddingPanel = vgui.Create( "DPanel", categoryScroller )
    paddingPanel:SetSize( 0, 0 )
    paddingPanel:Dock( TOP )

    cft.categoryDerma = {}

    local title = vgui.Create( "DLabel", frame )
    title:SetText( "" )
    title:SetFont( "RVR_CraftingHeader" )
    title:SetTextColor( yellow )

    local titleUnderline = vgui.Create( "DShape", frame )
    titleUnderline:SetType( "Rect" )
    titleUnderline:SetPos( w * 0.17, h * 0.13 )
    titleUnderline:SetSize( w * 0.79, 1 )
    titleUnderline:SetColor( yellow )

    cft.categoryDerma.title = title

    local categoryContent = vgui.Create( "DScrollPanel", frame )
    formatScrollbar( categoryContent:GetVBar() )
    categoryContent:SetPos( w * 0.16, h * 0.17 )
    categoryContent:SetSize( w * 0.81, h * 0.765 )

    cft.categoryDerma.categoryContent = categoryContent

    cft.setCategory( firstCat )
end

function cft.setCategory( category )
    local w, h = cft.openMenu:GetSize()

    local title = cft.categoryDerma.title
    title:SetText( category.name )
    title:SizeToContents()
    title:SetPos( w * 0.55 - title:GetWide() / 2, h * 0.013 )

    local content = cft.categoryDerma.categoryContent
    content:Clear()

    local recipePanels = {}
    for k, recipe in pairs( category.recipes ) do
        local panel = vgui.Create( "DPanel", content )
        panel:Dock( TOP )
        panel.Paint = nil
        panel:DockMargin( 0, 0, 10, 20 )
        panel:SetMouseInputEnabled( true )
        panel.prog = 0
        panel.targetProg = 0

        table.insert( recipePanels, panel )

        function panel:Think()
            if self.prog ~= self.targetProg then
                if self.prog > self.targetProg then
                    self.prog = math.max( self.prog - FrameTime() * 5, 0 )
                else
                    self.prog = math.min( self.prog + FrameTime() * 5, 1 )
                end

                if not self.content.populated then
                    cft.populateRecipePanel( panel.content, recipe )
                end
            else
                if self.prog == 0 and self.content.populated then
                    self.content:Clear()
                    self.content.populated = false
                end
            end

            self:SetTall( self:GetWide() * ( 0.152 + ( self.prog * 0.24 ) ) )
        end

        function panel:SetExpanded( ex )
            self.targetProg = ex and 1 or 0
            self.dropDownIndicator:SetImage( "rvr/icons/craftingmenu_dropdown" .. ( ex and "open" or "closed" ) .. ".png" )
        end

        function panel:GetExpanded()
            return self.targetProg == 1
        end

        local header = vgui.Create( "DImage", panel )
        header:SetImage( "rvr/backgrounds/craftingmenu_itembackground.png" )
        header:Dock( TOP )
        header:SetMouseInputEnabled( true )
        function header:OnMousePressed()
            for _, recipePanel in pairs( recipePanels ) do
                if recipePanel ~= panel then
                    recipePanel:SetExpanded( false )
                end
            end

            panel:SetExpanded( not panel:GetExpanded() )
        end

        function header:PerformLayout()
            self:SetTall( self:GetWide() * 0.152 )
        end

        local itemData = RVR.Items.getItemData( recipe.item )

        local itemIcon = vgui.Create( "RVR_ItemSlot", header )
        itemIcon:ConvertToGhost()
        itemIcon:SetImageColor( Color( 0, 0, 0, 0 ) )
        itemIcon:SetItemData( itemData, recipe.count or 1 )

        function itemIcon:PerformLayout()
            local _w, _h = header:GetSize()
            self:SetPos( _w * 0.015, _h * 0.05 )
            self:SetSize( _h * 0.9, _h * 0.9 )
        end

        local itemLabel = vgui.Create( "DLabel", header )
        itemLabel:SetText( itemData.displayName )
        itemLabel:SetFont( "RVR_BoxInventoryHeader" )
        itemLabel:SizeToContents()
        itemLabel:SetColor( brown )

        function itemLabel:PerformLayout()
            local _w = header:GetWide()
            self:SetPos( _w * 0.18, 0 )
            self:CenterVertical( 0.45 )
        end

        local dropDownIndicator = vgui.Create( "DImage", header )
        dropDownIndicator:SetImage( "rvr/icons/craftingmenu_dropdownclosed.png" )

        function dropDownIndicator:PerformLayout()
            local w, h = header:GetSize()
            local size = h * 0.35
            self:SetSize( size, size * ( 22 / 45 ) )
            self:SetPos( w - self:GetWide() - 20, 0 )
            self:CenterVertical( 0.45 )
        end

        panel.dropDownIndicator = dropDownIndicator

        local panelContentContainer = vgui.Create( "DPanel", panel )
        panelContentContainer.Paint = nil
        panelContentContainer:MoveToBack()

        function panelContentContainer:Think()
            local y = header:GetTall() * 0.5
            self:SetPos( 0, y )
            self:SetSize( header:GetWide(), panel:GetTall() - y )
        end

        local panelContent = vgui.Create( "DImage", panelContentContainer )
        panelContent:SetImage( "rvr/backgrounds/craftingmenu_itembackgroundextra.png" )
        panelContent:Dock( BOTTOM )
        panelContent:SetMouseInputEnabled( true )

        function panelContent:Think()
            self:SetTall( self:GetWide() * 0.301 )
            local prog = 1 - panel.prog
            self:DockMargin( 0, 0, 0, self:GetTall() * 0.5 * prog )
        end

        panel.content = panelContent
    end
end

function cft.populateRecipePanel( panel, recipe )
    panel.populated = true
    print( "populate" )
end

function cft.closeCraftingMenu()
    cft.openMenu:Remove()
    cft.openMenu = nil
end

concommand.Add("rvr_open_crafting_menu", function()
    cft.openCraftingMenu()
end )
