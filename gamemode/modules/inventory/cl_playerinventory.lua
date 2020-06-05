local inv = RVR.Inventory
local backgroundMat = Material( "icons/player_inventory_background.png" )

function inv.openPlayerInventory( inventory )
    local GM = GAMEMODE
    local w, h = ScrH() * 0.7 * 1.3, ScrH() * 0.7

    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "" )
    frame:SetDeleteOnClose( false )
    frame:SetSize( w, h )
    frame:SetDraggable( false )
    frame:ShowCloseButton( false )
    frame:Center()
    frame:MakePopup()

    function frame:Paint( w, h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, w, h )
    end

    function frame:OnClose()
        inv.closeInventory()
    end

    local closeButton = vgui.Create( "DImageButton", frame )
    closeButton:SetPos( w * 0.87, h * 0.05 )
    closeButton:SetSize( 50, 50 )
    closeButton:SetImage( "materials/icons/player_inventory_close.png" )
    function closeButton:DoClick()
        frame:Close()
    end


    local itemsPerRow = 7
    local gridWidthMult = 0.75
    local slotSize = ( w * gridWidthMult ) / itemsPerRow
    local imageSizeMult = 0.7
    local heightSpacingMult = 0.92
    local rowCount = math.floor( ( GM.Config.Inventory.PLAYER_INVENTORY_SLOTS - 1 ) / itemsPerRow ) + 1

    local startX = w * ( 1 - gridWidthMult ) * 0.5
    local startY = h * 0.89 - rowCount * slotSize
    for k = 1, GM.Config.Inventory.PLAYER_INVENTORY_SLOTS do
        local x = ( k - 1 ) % itemsPerRow
        local y = math.floor( ( k - 1 ) / itemsPerRow )

        local slot = vgui.Create( "RVR_ItemSlot", frame )
        slot:SetSize( slotSize * imageSizeMult, slotSize * imageSizeMult )
        local offsetMult = ( 1 - imageSizeMult ) / 2
        slot:SetPos( startX + slotSize * ( x + offsetMult ), startY + slotSize * heightSpacingMult * ( y + offsetMult ) )
        slot:SetLocationData( LocalPlayer(), k )
        local itemInfo = inventory.Inventory[k]
        if itemInfo then
            slot:SetItemData( itemInfo.item, itemInfo.count )
        end
    end

    local offset = GM.Config.Inventory.PLAYER_INVENTORY_SLOTS + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS

    local headSlot = vgui.Create( "RVR_ItemSlot", frame )
    headSlot:SetSize( slotSize * 0.5, slotSize * 0.5 )
    headSlot:SetPos( w * 0.662, h * 0.124 )
    headSlot:SetLocationData( LocalPlayer(), offset + 1 )

    local bodySlot = vgui.Create( "RVR_ItemSlot", frame )
    bodySlot:SetSize( slotSize * 0.5, slotSize * 0.5 )
    bodySlot:SetPos( w * 0.662, h * ( 0.124 + 0.085 ) )
    bodySlot:SetLocationData( LocalPlayer(), offset + 2 )

    local footSlot = vgui.Create( "RVR_ItemSlot", frame )
    footSlot:SetSize( slotSize * 0.5, slotSize * 0.5 )
    footSlot:SetPos( w * 0.662, h * ( 0.124 + 0.085 + 0.086 ) )
    footSlot:SetLocationData( LocalPlayer(), offset + 3 )

    return frame
end
