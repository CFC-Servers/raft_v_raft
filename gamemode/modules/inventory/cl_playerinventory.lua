local inv = RVR.Inventory
local backgroundMat = Material( "rvr/backgrounds/player_inventory_background.png" )

function inv.openPlayerInventory( inventory )
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
    closeButton:SetPos( w * 0.91, h * 0.05 )
    closeButton:SetSize( 50, 50 )
    closeButton:SetImage( "materials/rvr/icons/player_inventory_close.png" )

    function closeButton:DoClick()
        frame:Close()
    end

    local invScroller = vgui.Create( "RVR_InventoryScroller", frame )
    invScroller:SetSize( w * 0.435, h * 0.536 )
    invScroller:SetPos( w * 0.533, h * 0.345 )
    invScroller:SetSlotsPerRow( 4 )
    invScroller:SetInventory( inventory, config.PLAYER_HOTBAR_SLOTS + 1, inventory.MaxSlots )

    -- equipment slots
    local eSlotXMult = 0.38
    local eSlotYMult = 0.19
    local eSlotYSpacing = 0.25

    local iconNames = { "hat", "shirt", "pants" }
    local slotSize = invScroller:GetSlotSize()
    local equipMult = 1.08

    -- equipment slots indexes start at #hotbar + #inventory
    local equipmentSlotOffset = config.PLAYER_INVENTORY_SLOTS + config.PLAYER_HOTBAR_SLOTS

    for index = 1, 3 do
        local yOffset = ( index - 1 ) * eSlotYSpacing

        local slot = vgui.Create( "RVR_ItemSlot", frame )
        slot:SetImage( "materials/rvr/backgrounds/equip_slot_" .. iconNames[index] .. ".png" )
        slot:SetSize( slotSize * equipMult, slotSize * equipMult )
        slot:SetPos( w * eSlotXMult, h * ( eSlotYMult + yOffset ) )
        slot:SetLocationData( LocalPlayer(), equipmentSlotOffset + index )

        local itemInfo = inventory.Inventory[equipmentSlotOffset + index]

        if itemInfo then
            slot:SetItemData( itemInfo.item, itemInfo.count )
        end
    end

    local icon = vgui.Create( "DModelPanel", frame )
    icon:SetPos( w * 0.1, h * 0.15 )
    icon:SetSize( w * 0.24, h * 0.74 )
    icon:SetModel( LocalPlayer():GetModel() )
    icon:SetMouseInputEnabled( false )

    -- Go far away and zoom in, to give less of a "fish-eye" effect
    icon:SetCamPos( Vector( 100, 0, 35 ) )
    icon:SetLookAng( Angle( 0, 180, 0 ) )
    icon:SetFOV( 20 )
    icon:SetCursor( "none" )

    icon.Entity:SetMaterial( "models/debug/debugwhite" )
    icon:SetColor( Color( 0, 0, 0 ) )

    -- Disable default behaviour
    function icon:LayoutEntity( entity )
    end

    return frame
end
