RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory
local L = RVR.Localize

local backgroundMat = Material( "rvr/backgrounds/generic_menu_background.png" )

surface.CreateFont( "RVR_BoxInventoryHeader", {
    font = "Bungee Regular",
    size = ScrH() * 0.08,
    weight = 700,
} )

function inv.openBoxInventory( boxInventory, playerInventory )
    local config = GAMEMODE.Config.Inventory
    local w, h = ScrH() * 0.91, ScrH() * 0.7

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:SetDeleteOnClose( false )
    frame:SetSize( w, h )
    frame:SetDraggable( false )
    frame:ShowCloseButton( false )
    frame:CenterHorizontal()
    local x = frame:GetPos()
    frame:SetPos( x, 0.3 * ( ScrH() - h ) )
    frame:MakePopup()

    function frame:Paint( _w, _h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    function frame:OnClose()
        inv.closeInventory()
    end

    local closeButton = vgui.Create( "DImageButton", frame )
    closeButton:SetPos( w * 0.94, h * 0.03 )
    closeButton:SetSize( 30, 30 )
    closeButton:SetImage( "materials/rvr/icons/player_inventory_close.png" )
    function closeButton:DoClick()
        frame:Close()
    end

    local label = vgui.Create( "DLabel", frame )
    label:SetText( string.upper( boxInventory.Name or L( "storage" ) ) )
    label:SetTextColor( Color( 188, 162, 105 ) )
    label:SetFont( "RVR_BoxInventoryHeader" )
    label:SizeToContents()
    label:SetPos( 0, h * 0.03 )
    label:CenterHorizontal()

    local underline = vgui.Create( "DShape", frame )
    underline:SetType( "Rect" )
    underline:SetPos( w * 0.097, h * 0.12 )
    underline:SetSize( w * 0.8, 3 )
    underline:SetColor( Color( 188, 162, 105 ) )

    local ownInvScroller = vgui.Create( "RVR_InventoryScroller", frame )
    ownInvScroller:SetSize( w * 0.4, h * 0.38 )
    ownInvScroller:SetPos( w * 0.31, h * 0.56 )
    ownInvScroller:SetSlotsPerRow( 4 )
    -- First config.PLAYER_HOTBAR_SLOTS slots of player inventory are hotbar, skip these
    ownInvScroller:SetInventory( playerInventory, config.PLAYER_HOTBAR_SLOTS + 1, playerInventory.MaxSlots )

    local boxInvScroller = vgui.Create( "RVR_InventoryScroller", frame )
    boxInvScroller:SetSize( w * 0.853, h * 0.4 )
    boxInvScroller:SetPos( w * 0.097, h * 0.14 )
    boxInvScroller:SetSlotsPerRow( 8 )
    -- Make the box inventory look different
    boxInvScroller:SetSlotImage( "materials/rvr/backgrounds/dark_slot_background.png" )
    boxInvScroller:SetBackgroundImage( "materials/rvr/backgrounds/dark_inventory_scroller_background.png" )
    boxInvScroller:SetInventory( boxInventory )

    return frame
end
