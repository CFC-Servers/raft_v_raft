RVR.Crafting = RVR.Crafting or {}

local cft = RVR.Crafting
local backgroundMat = Material( "rvr/backgrounds/crafting_background.png" )
local categoriesBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categoriesbackground.png" )
local iconBackgroundMat = Material( "rvr/backgrounds/craftingmenu_categorybackground.png" )
local hammerIcon = Material( "rvr/icons/crafting_hammer.png" )

local yellow = Color( 188, 162, 105 )
local brown = Color( 91, 56, 34 )
local categoryMats = {}
local categoryMatsLoaded = false

--[[ TODO:
    Add bench entity using model Peri made
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
    function bar:SetUp( barSize, canvasSize )
        self.BarSize = barSize
        self.CanvasSize = math.max( canvasSize - barSize, 0.01 )

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

function cft.openCraftingMenu( craftingData )
    if cft.openMenu then
        cft.closeCraftingMenu()
    end

    if not categoryMatsLoaded then
        for _, category in pairs( cft.Recipes ) do
            categoryMats[category.name] = Material( category.icon )
        end
        categoryMatsLoaded = true
    end

    cft.craftingData = {
        state = craftingData.state
    }

    if craftingData.state ~= cft.STATE_WAITING then
        cft.craftingData.recipe = cft.Recipes[craftingData.categoryID].recipes[craftingData.recipeID]
        cft.craftingData.timeStart = craftingData.timeStart
    end

    local tier = craftingData.tier

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

    function frame:OnKeyCodePressed( key )
        local contextKey = input.GetKeyCode( input.LookupBinding( "+menu_context" ) )
        if key == contextKey then
            cft.closeCraftingMenu()
        end
    end

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

    cft.categoryDerma = {}
    cft.categoryDerma.buttons = {}

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

        cft.categoryDerma.buttons[category.categoryID] = categoryButton

        function categoryButton:DoClick()
            cft.setCategory( category )
        end

        function categoryButton:Paint( _w, _h )
            -- Background
            surface.SetDrawColor( self.selected and Color( 255, 255, 255 ) or Color( 180, 180, 180 ) )
            surface.SetMaterial( iconBackgroundMat )
            surface.DrawTexturedRect( 0, 0, _w, _h )

            -- Icon
            local margin = 10
            surface.SetMaterial( categoryMats[category.name] )
            surface.DrawTexturedRect( margin, margin, _w - ( margin * 2 ), _h - ( margin * 2 ) )

            if not self.showHammer then return end

            local hammerSize = 30

            local ang = 0
            if self.animateHammer then
                ang = math.deg( math.abs( math.sin( CurTime() * 3 ) ) )
            end

            local colVal = self.selected and 180 or 130
            surface.SetDrawColor( self.animateHammer and Color( colVal, 0, 0 ) or Color( 0, colVal, 0 ) )
            surface.SetMaterial( hammerIcon )
            surface.DrawTexturedRectRotated( _w - hammerSize + 8, _h - hammerSize + 5, hammerSize, hammerSize, ang )
        end
    end

    local paddingPanel = vgui.Create( "DPanel", categoryScroller )
    paddingPanel:SetSize( 0, 0 )
    paddingPanel:Dock( TOP )


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
    categoryContent:SetSize( w * 0.81, h * 0.68 )

    cft.categoryDerma.categoryContent = categoryContent

    cft.setCategory( firstCat )

    cft.createGrabButton( frame )

    cft.updateCraftingHammers()
end

function cft.setCategory( category )
    local w, h = cft.openMenu:GetSize()

    local title = cft.categoryDerma.title
    title:SetText( category.name )
    title:SizeToContents()
    title:SetPos( w * 0.55 - title:GetWide() / 2, h * 0.013 )

    for catID, btn in pairs( cft.categoryDerma.buttons ) do
        btn.selected = catID == category.categoryID
    end

    local content = cft.categoryDerma.categoryContent
    content:Clear()

    local recipePanels = {}
    cft.recipePanels = recipePanels
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

        local function clickHeader()
            for _, recipePanel in pairs( recipePanels ) do
                if recipePanel ~= panel then
                    recipePanel:SetExpanded( false )
                end
            end

            panel:SetExpanded( not panel:GetExpanded() )
        end

        local header = vgui.Create( "DImage", panel )
        header:SetImage( "rvr/backgrounds/craftingmenu_itembackground.png" )
        header:Dock( TOP )
        header:SetMouseInputEnabled( true )
        header.OnMousePressed = clickHeader

        function header:PerformLayout()
            self:SetTall( self:GetWide() * 0.152 )
        end

        local itemData = RVR.Items.getItemData( recipe.item )

        local itemIcon = vgui.Create( "RVR_ItemSlot", header )
        itemIcon:ConvertToGhost()
        itemIcon:SetImageColor( Color( 0, 0, 0, 0 ) )
        itemIcon:SetItemData( itemData, recipe.count )
        itemIcon.OnMousePressed = clickHeader
        panel.icon = itemIcon

        function itemIcon:PerformLayout()
            local _w, _h = header:GetSize()
            self:SetPos( _w * 0.015, _h * 0.05 )
            self:SetSize( _h * 0.9, _h * 0.9 )
        end

        function itemIcon:PaintOver( _w, _h )
            if not self.showHammer then return end

            local hammerSize = 30

            local ang = 0
            if self.animateHammer then
                ang = math.deg( math.abs( math.sin( CurTime() * 3 ) ) )
            end

            surface.SetDrawColor( self.animateHammer and Color( 180, 0, 0 ) or Color( 0, 180, 0 ) )
            surface.SetMaterial( hammerIcon )
            surface.DrawTexturedRectRotated( _w - hammerSize + 5, _h - hammerSize + 5, hammerSize, hammerSize, ang )
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
            local _w, _h = header:GetSize()
            local size = _h * 0.35
            self:SetSize( size, size * ( 22 / 45 ) )
            self:SetPos( _w - self:GetWide() - 20, 0 )
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
        panel.recipe = recipe
    end

    cft.updateCraftingHammers()
end

function cft.populateRecipePanel( panel, recipe )
    panel:Clear()
    panel.populated = true

    local ingredientContainer = vgui.Create( "DPanel", panel )
    ingredientContainer.Paint = nil

    panel.ingredientLabels = {}

    local keys = table.GetKeys( recipe.ingredients )
    table.sort( keys )
    for k, ingredient in pairs( keys ) do
        local count = recipe.ingredients[ingredient]

        local ingredPanel = vgui.Create( "DPanel", ingredientContainer )
        ingredPanel:Dock( LEFT )
        ingredPanel:DockMargin( 10, 0, 10, 0 )
        ingredPanel.Paint = nil

        function ingredPanel:PerformLayout()
            self:SetWide( self:GetTall() * 0.75 )
        end

        local itemSlot = vgui.Create( "RVR_ItemSlot", ingredPanel )
        itemSlot:ConvertToGhost()
        itemSlot:SetItemData( RVR.Items.getItemData( ingredient ), 1 )
        itemSlot:SetImage( "rvr/backgrounds/craftingmenu_ingredient.png" )
        itemSlot:Dock( TOP )

        function itemSlot:PerformLayout()
            self:SetTall( self:GetWide() )
        end

        local countLabelContainer = vgui.Create( "DPanel", ingredPanel )
        countLabelContainer:Dock( FILL )
        countLabelContainer.Paint = nil

        local countLabel = vgui.Create( "DLabel", countLabelContainer )
        countLabel:SetFont( "RVR_CraftingLabel" )

        function countLabel:UpdateText()
            local has = RVR.Inventory.selfGetItemCount( ingredient )
            self:SetTextColor( has >= count and brown or Color( 180, 0, 0 ) )
            self:SetText( has .. "/" .. count )
        end

        function countLabel:PerformLayout()
            self:SizeToContents()
            self:Center()
        end

        countLabel:UpdateText()

        table.insert( panel.ingredientLabels, countLabel )

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
        self:SetTall( h * 0.58 )
        self:SetPos( 0, h * 0.22 )

        self:SizeToChildren( true, false )
        self:SetWide( self:GetWide() + 10 ) -- Account for right margin >:(

        self:CenterHorizontal()
    end

    cft.createCraftButton( panel, recipe )
end

function cft.createCraftButton( panel, recipe )
    local canCraft

    local tooltip
    local btnColor

    local isSelf = cft.craftingData.recipe == recipe

    if cft.craftingData.state == cft.STATE_WAITING then
        canCraft = true
        for name, count in pairs( recipe.ingredients ) do
            local has = RVR.Inventory.selfGetItemCount( name )
            if has < count then
                canCraft = false
                tooltip = "You don't have enough materials!"
                btnColor = Color( 255, 150, 150 )
                break
            end
        end
    elseif isSelf then
        if cft.craftingData.state == cft.STATE_CRAFTED then
            local itemInstance = RVR.Items.getItemInstance( recipe.item )

            if not RVR.Inventory.selfCanFitItem( itemInstance, recipe.count ) then
                canCraft = false
                tooltip = "No space in inventory"
                btnColor = Color( 255, 150, 150 )
            else
                canCraft = true
            end
        else
            canCraft = false
            tooltip = cft.craftingData.state == cft.STATE_GRAB_REQUEST and "Grabbing..." or "Crafting..."
            btnColor = Color( 150, 150, 150 )
        end
    else
        canCraft = false
        tooltip = "Another item is crafting"
        btnColor = Color( 255, 150, 150 )
    end

    if panel.craftButton then panel.craftButton:Remove() end
    if panel.timeLabel then panel.timeLabel:Remove() end

    local craftButton = vgui.Create( "DImage", panel )
    if isSelf and ( cft.craftingData.state == cft.STATE_CRAFTED or cft.craftingData.state == cft.STATE_GRAB_REQUEST ) then
        craftButton:SetImage( "rvr/icons/craftingmenu_grabbutton.png" )
    else
        craftButton:SetImage( "rvr/icons/craftingmenu_craftbutton.png" )
    end

    craftButton:SetCursor( canCraft and "hand" or "no" )
    if not canCraft then
        craftButton:SetTooltip( tooltip )
        craftButton:SetImageColor( btnColor )
    end
    craftButton:SetMouseInputEnabled( true )

    panel.craftButton = craftButton

    function craftButton:PerformLayout()
        local w, h = panel:GetSize()
        local btnH = h * 0.16
        self:SetSize( btnH * ( 98 / 35 ), btnH )
        self:SetPos( w - self:GetWide() - 5, h - self:GetTall() - 5 )
    end

    function craftButton:OnMousePressed( btn )
        if btn ~= MOUSE_LEFT then return end
        if not canCraft then return end

        if cft.craftingData.state == cft.STATE_CRAFTED then
            cft.craftingData.state = cft.STATE_GRAB_REQUEST

            net.Start( "RVR_Crafting_Grab" )
            net.SendToServer()
        else
            cft.craftingData.state = cft.STATE_CRAFT_REQUEST
            cft.craftingData.recipe = recipe

            net.Start( "RVR_Crafting_AttemptCraft" )
            net.WriteInt( recipe.categoryID, 8 )
            net.WriteInt( recipe.recipeID, 8 )
            net.SendToServer()
        end

        cft.createCraftButton( panel, recipe )
        cft.createGrabButton( cft.openMenu )
    end

    function craftButton:PaintOver( w, h )
        if not cft.craftingData then return end
        if cft.craftingData.recipe ~= recipe then return end
        if cft.craftingData.state ~= cft.STATE_CRAFTING then return end

        local prog = ( CurTime() - cft.craftingData.timeStart ) / recipe.timeToCraft

        prog = math.Clamp( prog, 0, 1 )

        surface.SetDrawColor( Color( 0, 150, 0, 80 ) )
        surface.DrawRect( 0, 0, w * prog, h )
    end

    local timeLabel = vgui.Create( "DLabel", panel )
    timeLabel:SetTextColor( brown )
    timeLabel:SetFont( "RVR_CraftingLabel" )
    timeLabel:SizeToContents()

    function timeLabel:PerformLayout()
        self:SetTall( craftButton:GetTall() )
        local w, h = panel:GetSize()
        self:SetPos( w - craftButton:GetWide() - 5 - self:GetWide(), h - self:GetTall() - 5 )
    end

    function timeLabel:Think()
        local time = 0
        if cft.craftingData.state ~= cft.STATE_CRAFTING or cft.craftingData.recipe ~= recipe then
            time = recipe.timeToCraft
        else
            time = math.Clamp( math.ceil( recipe.timeToCraft - ( CurTime() - cft.craftingData.timeStart ) ), 0, recipe.timeToCraft )
        end
        timeLabel:SetText( string.FormattedTime( time, "%02i:%02i" ) )
    end

    panel.timeLabel = timeLabel

end

function cft.createGrabButton( frame )
    if frame.grabButton then
        frame.grabButton:Remove()
    end

    local w, h = frame:GetSize()

    local state = cft.craftingData.state
    local recipe = cft.craftingData.recipe

    local canGrab = state == cft.STATE_CRAFTED
    if canGrab then
        local itemInstance = RVR.Items.getItemInstance( recipe.item )

        canGrab = RVR.Inventory.selfCanFitItem( itemInstance, recipe.count )
    end

    local grabButton = vgui.Create( "DImage", frame )
    grabButton:SetImage( "rvr/icons/craftingmenu_biggrabbutton.png" )
    grabButton:SetMouseInputEnabled( true )
    grabButton:SetCursor( canGrab and "hand" or "no" )
    if not canGrab then
        if state == cft.STATE_CRAFTED then
            grabButton:SetImageColor( Color( 255, 150, 150 ) )
            grabButton:SetTooltip( "No space in inventory" )
        else
            grabButton:SetImageColor( Color( 150, 150, 150 ) )
        end
    end
    grabButton:SetPos( w * 0.16, h * 0.885 )
    grabButton:SetWide( w * 0.81 )

    function grabButton:PerformLayout()
        self:SetTall( self:GetWide() * ( 56 / 747 ) )
    end

    function grabButton:PaintOver( _w, _h )
        if cft.craftingData.state ~= cft.STATE_CRAFTING then return end

        local prog = ( CurTime() - cft.craftingData.timeStart ) / recipe.timeToCraft

        prog = math.Clamp( prog, 0, 1 )

        surface.SetDrawColor( Color( 0, 150, 0, 80 ) )
        surface.DrawRect( 0, 0, _w * prog, _h )
    end

    function grabButton:OnMousePressed( btn )
        if btn ~= MOUSE_LEFT then return end
        if not canGrab then return end

        cft.craftingData.state = cft.STATE_GRAB_REQUEST

        net.Start( "RVR_Crafting_Grab" )
        net.SendToServer()

        cft.reloadCraftButtons()
    end

    frame.grabButton = grabButton
end

function cft.reloadCraftButtons( reloadIngredients )
    for k, panel in pairs( cft.recipePanels or {} ) do
        if panel:GetExpanded() then
            cft.createCraftButton( panel.content, panel.recipe )
            if reloadIngredients then
                for _, label in pairs( panel.content.ingredientLabels ) do
                    label:UpdateText()
                end
            end
        end
    end
    cft.createGrabButton( cft.openMenu )
end

function cft.updateCraftingHammers()
    for id, btn in pairs( cft.categoryDerma.buttons ) do
        btn.showHammer = false
        if cft.craftingData.state ~= cft.STATE_WAITING and cft.craftingData.recipe.categoryID == id then
            btn.showHammer = true
            btn.animateHammer = cft.craftingData.state == cft.STATE_CRAFTING
        end
    end

    for k, panel in pairs( cft.recipePanels ) do
        local icon = panel.icon
        local recipe = panel.recipe

        icon.showHammer = false
        if cft.craftingData.state ~= cft.STATE_WAITING and cft.craftingData.recipe == recipe then
            icon.showHammer = true
            icon.animateHammer = cft.craftingData.state == cft.STATE_CRAFTING
        end
    end
end

hook.Add( "RVR_Inventory_HotbarCanScroll", "RVR_Crafting_stopScroll", function()
    if cft.openMenu then
        return false
    end
end )

function cft.closeCraftingMenu()
    cft.openMenu:Remove()
    cft.openMenu = nil
    cft.craftingData = nil
    cft.recipePanels = nil

    net.Start( "RVR_Crafting_CloseCraftingMenu" )
    net.SendToServer()
end

net.Receive( "RVR_Crafting_CraftResponse", function()
    if not cft.craftingData then return end
    local state = net.ReadInt( 4 )

    cft.craftingData.state = state
    if state == cft.STATE_WAITING or state == cft.STATE_CRAFTING then
        cft.reloadCraftButtons( true )
    end
    if state == cft.STATE_CRAFTING then
        cft.craftingData.timeStart = CurTime()
        timer.Simple( cft.craftingData.recipe.timeToCraft, function()
            if not cft.craftingData then return end -- TODO: Check we're in same menu or something
            cft.craftingData.state = cft.STATE_CRAFTED
            cft.reloadCraftButtons()
            cft.updateCraftingHammers()
        end )
    end

    cft.updateCraftingHammers()
end )

net.Receive( "RVR_Crafting_OpenCraftingMenu", function()
    cft.openCraftingMenu( net.ReadTable() )
end )

hook.Add( "PlayerBindPress", "RVR_Crafting", function( _, bind, pressed )
    if not pressed then return end
    if bind ~= "+menu_context" then return end

    net.Start( "RVR_Crafting_OpenCraftingMenu" )
    net.SendToServer()
end )
