local inv = RVR.Inventory
local backgroundMat = Material( "icons/player_inventory_background.png" )

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
end

function inv.openPlayerInventory( inventory )
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

    local scrollWidth = w * 0.435
    local scrollPanel = vgui.Create( "DScrollPanel", frame )
    scrollPanel:SetPos( w * 0.533, h * 0.481 )
    scrollPanel:SetSize( scrollWidth, h * 0.397 )
    formatScrollbar( scrollPanel:GetVBar() )

    local slotsPerRow = 4
    local rows = math.ceil( GM.Config.Inventory.PLAYER_INVENTORY_SLOTS / slotsPerRow )
    local slotSize = ( scrollWidth * 0.94 ) / slotsPerRow
    local spacing = slotSize * 0.2

    local canvasPanel = vgui.Create( "DPanel", scrollPanel )
    canvasPanel:SetSize( slotSize * slotsPerRow, slotSize * rows )
    canvasPanel.Paint = nil

    for y = 0, rows - 1 do
        for x = 0, slotsPerRow - 1 do
            local index = y * slotsPerRow + x + 1
            if index > GM.Config.Inventory.PLAYER_INVENTORY_SLOTS then break end

            index = index + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS

            local slot = vgui.Create( "RVR_ItemSlot", canvasPanel )
            slot:SetSize( slotSize - spacing, slotSize - spacing )
            slot:SetPos( ( x * slotSize ) + spacing * 0.5, ( y * slotSize ) + spacing * 0.5 )

            slot:SetLocationData( LocalPlayer(), index )
            local itemInfo = inventory.Inventory[index]
            if itemInfo then
                slot:SetItemData( itemInfo.item, itemInfo.count )
            end
        end
    end

    local eSlotXMult = 0.38
    local eSlotYMult = 0.19
    local eSlotYSpacing = 0.25

    local iconNames = { "hat", "shirt", "pants" }

    local equipmentSlotOffset = GM.Config.Inventory.PLAYER_INVENTORY_SLOTS + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS
    for index = 1, 3 do

        local yOffset = ( index - 1 ) * eSlotYSpacing

        local slot = vgui.Create( "RVR_ItemSlot", frame )
        slot:SetImage( "materials/icons/equip_slot_" .. iconNames[index] .. ".png" )
        slot:SetSize( slotSize * 1.2, slotSize * 1.2 )
        slot:SetPos( w * eSlotXMult, h * ( eSlotYMult + yOffset ) )
        slot:SetLocationData( LocalPlayer(), equipmentSlotOffset + index )

        local itemInfo = inventory.Inventory[equipmentSlotOffset + index]
        if itemInfo then
            slot:SetItemData( itemInfo.item, itemInfo.count )
        end
    end

    return frame
end
