RVR.Crafting = RVR.Crafting or {}

local cft = RVR.Crafting
local backgroundMat = Material( "rvr/backgrounds/crafting_background.png" )
local categoriesBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categoriesbackground.png" )
local iconBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categorybackground.png" )
local yellow = Color( 188, 162, 105 )
local brown = Color( 91, 56, 34 )
local categoryMats = {}
local categoryMatsLoaded = false

--[[ CLIENTSIDE TODO:
    Create ingredient panels
        Show ingredient data + counts
        requires making "get total of item" functions, probably in another branch so PCL can use
    Somehow show which category is selected
    Show craft progress
        Could be done by graying out then filling up the craft button

    Redo item tooltips to show much more info

]]

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

surface.CreateFont( "RVR_CraftingLabel", {
    font = "Bungee Regular",
    size = ScrH() * 0.07,
    weight = 700,
} )

function cft.openCraftingMenu( tier )
    if cft.openMenu then
        cft.closeCraftingMenu()
    end

    if not categoryMatsLoaded then
        for _, category in pairs( cft.Recipes ) do
            categoryMats[category.name] = Material( category.icon )
        end
        categoryMatsLoaded = true
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
        if #category.recipes == 0 then continue end
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

    local ingredientContainer = vgui.Create( "DPanel", panel )
    ingredientContainer.Paint = nil

    local canAfford = true

    local keys = table.GetKeys( recipe.ingredients )
    for k, ingredient in pairs( keys ) do
        local count = recipe.ingredients[ingredient]

        local ingredPanel = vgui.Create( "DPanel", ingredientContainer )
        ingredPanel:Dock( LEFT )
        ingredPanel:DockMargin( 10, 0, 10, 0 )
        ingredPanel.Paint = nil

        function ingredPanel:PerformLayout()
            self:SetWide( self:GetTall() * 0.8 )
        end

        local itemSlot = vgui.Create( "RVR_ItemSlot", ingredPanel )
        itemSlot:ConvertToGhost()
        itemSlot:SetItemData( RVR.Items.getItemData( ingredient ), 1 )
        itemSlot:Dock( TOP )

        function itemSlot:PerformLayout()
            self:SetTall( self:GetWide() )
        end

        local countLabelContainer = vgui.Create( "DPanel", ingredPanel )
        countLabelContainer:Dock( FILL )
        countLabelContainer.Paint = nil

        local countLabel = vgui.Create( "DLabel", countLabelContainer )
        countLabel:SetFont( "RVR_CraftingLabel" )

        local has = 0 -- RVR.Inventory.selfGetItemCount( ingredient )
        countLabel:SetTextColor( has >= count and brown or Color( 180, 0, 0 ) )

        if has < count then canAfford = false end

        countLabel:SetText( has .. "/" .. count )

        function countLabel:PerformLayout()
            self:SizeToContents()
            self:Center()
        end

        if k ~= #keys then
            local plus = vgui.Create( "DPanel", ingredientContainer )
            plus:Dock( LEFT )

            function plus:PerformLayout()
                local h = ingredientContainer:GetTall()
                local plusH = h * 0.2
                local yMult = 0.35


                self:DockMargin( 0, ( h - plusH ) * yMult, 0, ( h - plusH ) * ( 1 - yMult ) )
                self:SetWide( self:GetTall() )
            end

            function plus:Paint( w, h )
                draw.RoundedBox( 0, 0, math.Round( h * 0.35 ), w, math.Round( h * 0.3 ), brown )
                draw.RoundedBox( 0, math.Round( w * 0.35 ), 0, math.Round( w * 0.3 ), h, brown )
            end
        end

    end

    function ingredientContainer:PerformLayout()
        local h = panel:GetTall()
        self:SetTall( h * 0.6 )
        self:SetPos( 0, h * 0.2 )

        self:SizeToChildren( true, false )
        self:SetWide( self:GetWide() + 10 ) -- Account for right margin >:(

        self:CenterHorizontal()
    end

    local craftButton = vgui.Create( "DImage", panel )
    craftButton:SetImage( "rvr/icons/craftingmenu_craftbutton.png" )
    craftButton:SetCursor( canAfford and "hand" or "no" )
    craftButton:SetImageColor( canAfford and Color( 255, 255, 255 ) or Color( 255, 150, 150 ) )
    craftButton:SetMouseInputEnabled( true )

    function craftButton:PerformLayout()
        local w, h = panel:GetSize()
        local btnH = h * 0.16
        self:SetSize( btnH * ( 98 / 35 ), btnH )
        self:SetPos( w - craftButton:GetWide() - 5, h - craftButton:GetTall() - 5 )
    end

    function craftButton:OnMousePressed( btn )
        if btn ~= MOUSE_LEFT then return end
        if not canAfford then return end
        print( "Craft" )
    end
end

function cft.closeCraftingMenu()
    cft.openMenu:Remove()
    cft.openMenu = nil
end

concommand.Add("rvr_open_crafting_menu", function()
    cft.openCraftingMenu()
end )
