local cft = RVR.Crafting
local backgroundMat = Material( "rvr/backgrounds/crafting_background.png" )
local iconBackgroundMat = Material( "rvr/backgrounds/crafting_icon_background.png" )
local categoryMats = {}

-- Pre-loading category materials
for _, category in pairs( cft.Recipes ) do
    categoryMats[category.categoryName] = Material( category.icon )
end

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
    frame:Center()
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

    local padding = w * 0.01
    categoryScroller:SetPos( padding, padding )
    categoryScroller:SetSize( w * 0.15 - padding * 2, h - padding * 2 )
    categoryScroller:GetCanvas():InvalidateLayout( true )

    function categoryScroller:Paint( w, h )
        draw.RoundedBox( 0, 0, 0, w, h, Color( 255, 0, 0 ) )
    end

    for _, category in ipairs( cft.Recipes ) do
        if category.minTier > tier then continue end

        local categoryButton = vgui.Create( "DImageButton", categoryScroller )
        categoryButton:Dock( TOP )
        categoryButton:DockMargin( 10, 10, 10, 10 )
        categoryButton:InvalidateParent( true )
        categoryButton:SetTall( categoryButton:GetWide() )

        function categoryButton:DoClick()
            categoryTitle:SetText( category.categoryName )
        end

        function categoryButton:Paint( _w, _h )
            -- Background
            surface.SetMaterial( iconBackgroundMat )
            surface.SetDrawColor( Color( 255, 255, 255 ) )
            surface.DrawTexturedRect( 0, 0, _w, _h )

            -- Icon
            local margin = 5
            surface.SetMaterial( categoryMats[category.categoryName] )
            surface.SetDrawColor( Color( 120, 100, 100 ) )
            surface.DrawTexturedRect( margin, margin, _w - ( margin * 2 ), _h - ( margin * 2 ) )
        end
    end

    -- local categoryTitle = vgui.Create( "DLabel", frame )
    -- categoryTitle:SetFont( "RVR_BoxInventoryHeader" )
    -- categoryTitle:SetText( "Crafting" )



    -- local itemsDisplay = vgui.Create( "DPanel", frame )

    -- function itemsDisplay:Paint( _w, _h )
    -- end


end

function cft.closeCraftingMenu()
    cft.openMenu:Remove()
    cft.openMenu = nil
end

concommand.Add("rvr_open_crafting_menu", function()
    cft.openCraftingMenu()
end )
