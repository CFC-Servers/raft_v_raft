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

    function frame:Paint( _w, _h )
        surface.SetMaterial( backgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
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
    local inventoryBottomMult = 0.47

    local startX = w * ( 1 - gridWidthMult ) * 0.5
    local startY = h * inventoryBottomMult
    for k = 1, GM.Config.Inventory.PLAYER_INVENTORY_SLOTS do
        local itemSlotNum = k + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS

        -- Work out grid position, where 0, 0 is top left slot
        local gridX = ( k - 1 ) % itemsPerRow
        local gridY = math.floor( ( k - 1 ) / itemsPerRow )

        -- Work out real position, offset to account to imageSizeMult
        local imageOffsetMult = ( 1 - imageSizeMult ) / 2
        local x = startX + slotSize * ( gridX + imageOffsetMult )
        local y = startY + slotSize * heightSpacingMult * ( gridY + imageOffsetMult )

        -- Make the slot
        local slot = vgui.Create( "RVR_ItemSlot", frame )
        slot:SetSize( slotSize * imageSizeMult, slotSize * imageSizeMult )
        slot:SetPos( x, y )

        -- Setup slot location and item data
        slot:SetLocationData( LocalPlayer(), itemSlotNum )
        local itemInfo = inventory.Inventory[itemSlotNum]
        if itemInfo then
            slot:SetItemData( itemInfo.item, itemInfo.count )
        end
    end

    local eSlotXMult = 0.662
    local eSlotYMult = 0.124
    local eSlotYSpacing = 0.085

    local equipmentSlotOffset = GM.Config.Inventory.PLAYER_INVENTORY_SLOTS + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS
    for index = 1, 3 do

        local yOffset = ( index - 1 ) * eSlotYSpacing

        local slot = vgui.Create( "RVR_ItemSlot", frame )
        slot:SetSize( slotSize * 0.5, slotSize * 0.5 )
        slot:SetPos( w * eSlotXMult, h * ( eSlotYMult + yOffset ) )
        slot:SetLocationData( LocalPlayer(), equipmentSlotOffset + index )
    end

    return frame
end
