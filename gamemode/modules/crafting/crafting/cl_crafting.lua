local cft = RVR.Crafting
local backgroundMat = Material( "rvr/backgrounds/crafting_background.png" )
local iconBackgroundMat = Material( "rvr/backgrounds/crafting_icon_background.png" )
local categoryMats = {}

-- Pre-loading category materials
for _, category in pairs( cft.Recipes ) do
    categoryMats[category.categoryName] = Material( category.icon )
end

function cft.openCraftingMenu()
    local w = ScrW() * 0.3
    local h = ScrH() * 0.6

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:SetSize( w, h )
    frame:SetPos( 10, 10 )
    frame:SetDraggable( false )
    frame:MakePopup()

    function frame:Paint( _w, _h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    function frame:OnClose()
        --cft.closeCraftingMenu()
    end

    local hScroll = vgui.Create( "DHorizontalScroller", frame )
    hScroll:Dock( TOP )
    hScroll:SetTall( 100 )
    hScroll:SetOverlap( -5 )

    local categoryTitle = vgui.Create( "DLabel", frame )
    categoryTitle:SetFont( "HL2MPTypeDeath" )
    categoryTitle:SetText( "Crafting" )
    categoryTitle:SizeToContents()
    categoryTitle:Dock( TOP )

    for _, category in pairs( cft.Recipes ) do
        local categoryButton = vgui.Create( "DButton", hScroll )
        categoryButton:SetText( "" )
        categoryButton:InvalidateParent( true )

        hScroll:AddPanel( categoryButton )

        categoryButton:SetWide( categoryButton:GetTall() )
        categoryButton.DoClick = function()
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
end

concommand.Add("rvr_open_crafting_menu", function()
    cft.openCraftingMenu()
end )
