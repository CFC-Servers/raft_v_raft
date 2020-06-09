RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

local backgroundMat = Material( "icons/generic_menu_background.png" )

function inv.openBoxInventory( boxInventory, playerInventory )
    local GM = GAMEMODE
    local w, h = ScrH() * 0.7 * 1.3, ScrH() * 0.7
    local yMult = 0.3 -- 0.5 means center Y

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:SetDeleteOnClose( false )
    frame:SetSize( w, h )
    frame:SetDraggable( false )
    frame:ShowCloseButton( false )
    frame:SetPos( ( ScrW() - w ) / 2, ( ScrH() - h ) * yMult )
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
    closeButton:SetPos( w * 0.91, h * 0.05 )
    closeButton:SetSize( 50, 50 )
    closeButton:SetImage( "materials/icons/player_inventory_close.png" )
    function closeButton:DoClick()
        frame:Close()
    end

    local invScroller = vgui.Create( "RVR_InventoryScroller", frame )
    invScroller:SetSize( w * 0.435, h * 0.397 )
    invScroller:SetPos( w * 0.533, h * 0.481 )
    invScroller:SetSlotsPerRow( 4 )
    invScroller:SetInventory( LocalPlayer(), playerInventory, GM.Config.Inventory.PLAYER_HOTBAR_SLOTS + 1, playerInventory.MaxSlots )

    return frame
end