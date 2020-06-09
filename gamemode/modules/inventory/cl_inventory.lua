RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

include( "cl_itemslot.lua" )
include( "cl_playerinventory.lua" )
include( "cl_boxinventory.lua" )

local cursorSlotSize = 60

net.Receive( "RVR_OpenInventory", function()
    local inventory = net.ReadTable()
    local isSelf = net.ReadBool()

    local plyInventory = inventory
    if not isSelf then
        plyInventory = net.ReadTable()
    end

    for k = 1, GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS do
        local data = plyInventory.Inventory[k]
        if data then
            inv.hotbar.slots[k]:SetItemData( data.item, data.count )
        end
    end

    local invType = inventory.InventoryType

    if invType == "PlayerUpdate" then
        return
    elseif invType == "Player" then
        inv.openInventory = inv.openPlayerInventory( inventory )
    elseif invType == "Box" then
        inv.openInventory = inv.openBoxInventory( inventory, plyInventory )
    end

    inv.enableCursorSlot()

    function inv.openInventory:OnKeyCodePressed( key )
        if key == inv.openInventoryKey then
            inv.closeInventory()
        end
    end
end )

net.Receive( "RVR_UpdateInventorySlot", function()
    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local hasSlotData = net.ReadBool()
    local slotData
    if hasSlotData then
        slotData = net.ReadTable()
    end

    if ent == LocalPlayer() and position == -1 then
        if hasSlotData then
            inv.setCursorItemData( slotData.item, slotData.count )
        else
            inv.clearCursorItemData()
        end
        return
    end

    for k, panel in pairs( inv.ItemSlots or {} ) do
        local slotEnt, slotPos = panel:GetLocationData()
        if slotEnt == ent and slotPos == position then
            -- Found the slot
            if hasSlotData then
                panel:SetItemData( slotData.item, slotData.count )
            else
                panel:ClearItemData()
            end

            break
        end
    end
end )

hook.Add( "PlayerBindPress", "RVR_Inventory", function( _, bind, pressed )
    if not pressed then return end

    if bind == "+menu" then
        inv.openInventoryKey = input.GetKeyCode( input.LookupBinding( "+menu" ) )
        net.Start( "RVR_OpenInventory" )
        net.SendToServer()

        return true
    elseif string.StartWith( bind, "slot" ) then
        local slotNum = tonumber( string.sub( bind, 5 ) )
        if not slotNum then return end

        inv.setHotbarSlot( slotNum )

        return true
    end
end )

concommand.Add( "RVR_closeInv", inv.closeInventory )

function inv.closeInventory()
    if inv.openInventory then
        inv.openInventory:Remove()
        inv.openInventory = nil
    end

    inv.disableCursorSlot()
    net.Start( "RVR_CloseInventory" )
    net.SendToServer()
end

function inv.enableCursorSlot()
    inv.showCursorItem = true
    inv.clearCursorItemData()
end

function inv.disableCursorSlot()
    inv.showCursorItem = false
    inv.clearCursorItemData()
end

function inv.setCursorItemData( item, count )
    inv.cursorItem = item
    inv.cursorItemMaterial = Material( string.sub( item.icon, 11 ) ) -- Remove "material/" from icon path
    inv.cursorItemCount = count
end

function inv.clearCursorItemData()
    inv.cursorItem = nil
    inv.cursorItemMaterial = nil
    inv.cursorItemCount = nil
end

function inv.getCursorItemData()
    return inv.cursorItem, inv.cursorItemCount
end

hook.Add( "PostRenderVGUI", "RVR_DrawCursorItem", function()
    if not inv.showCursorItem or not inv.cursorItemMaterial then return end

    local mx, my = gui.MousePos()
    local x, y = mx - cursorSlotSize / 2, my - cursorSlotSize / 2

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( inv.cursorItemMaterial )
    surface.DrawTexturedRect( x, y, cursorSlotSize, cursorSlotSize )

    if inv.cursorItemCount <= 1 then return end

    local countText = tostring( inv.cursorItemCount )
    surface.SetFont( "DermaLarge" )
    local tw, th = surface.GetTextSize( countText )
    local tx = x + cursorSlotSize - tw - 1
    local ty = y + cursorSlotSize - th + 5

    surface.SetTextColor( 200, 200, 200 )
    surface.SetTextPos( tx, ty )
    surface.DrawText( countText )
end )

hook.Add( "GUIMousePressed", "RVR_InventoryDropItem", function( code, aimVector )
    if not inv.openInventory then return end
    local mx, my = gui.MousePos()

    local panelX, panelY = inv.openInventory:GetPos()
    local panelW, panelH = inv.openInventory:GetSize()

    local onBorderX = mx < panelX or mx > panelX + panelW
    local onBorderY = my < panelY or my > panelY + panelH

    if not onBorderX and not onBorderY then return end

    local item, count = inv.getCursorItemData()

    if not item then return end

    if code == MOUSE_RIGHT then count = 1 end

    net.Start( "RVR_DropCursorItem" )
    net.WriteInt( count, 8 )
    net.SendToServer()
end )

local hotbarBackgroundMat = Material( "icons/player_hotbar_background.png" )

function inv.makeHotbar()
    local GM = GAMEMODE

    inv.hotbar = inv.hotbar or {}
    local hotbar = inv.hotbar

    if hotbar.frame then hotbar.frame:Remove() end
    local w, h = ScrW(), ScrH()

    local slotCount = GM.Config.Inventory.PLAYER_HOTBAR_SLOTS
    local innerHotbarWidth = w * 0.5
    local slotSpacing = 0 -- as percent of slotWidth

    local horizontalPadding = 0.05
    local verticalPadding = 0.1

    local slotSize = innerHotbarWidth / slotCount
    local innerHotbarHeight = slotSize

    local hotbarHeight = innerHotbarHeight * ( 1 + verticalPadding * 2 )
    local hotbarWidth = innerHotbarWidth + ( innerHotbarHeight * horizontalPadding * 2 )

    hotbar.frame = vgui.Create( "DFrame" )
    hotbar.frame:SetPos( ( w - hotbarWidth ) * 0.5, h - hotbarHeight )
    hotbar.frame:SetSize( hotbarWidth, hotbarHeight )
    hotbar.frame:SetTitle( "" )
    hotbar.frame:ShowCloseButton( false )
    hotbar.frame.bgColor = Color( 100, 100, 100 )
    function hotbar.frame:Paint( _w, _h )
        surface.SetMaterial( hotbarBackgroundMat )
        surface.SetDrawColor( Color( 255, 255, 255 ) )
        surface.DrawTexturedRect( 0, 0, _w, _h )
    end

    hotbar.slots = {}
    hotbar.selectedSlot = 0

    local offsetY = ( hotbarHeight - innerHotbarHeight ) * 0.5
    local offsetX = ( hotbarWidth - innerHotbarWidth ) * 0.5

    for k = 1, slotCount do
        local imageSizeMult = 1 - slotSpacing

        local slot = vgui.Create( "RVR_ItemSlot", hotbar.frame )
        slot:SetSize( slotSize * imageSizeMult, slotSize * imageSizeMult )
        slot:SetPos( offsetX + ( k - 1 ) * slotSize, offsetY )
        slot:SetLocationData( LocalPlayer(), k )

        hotbar.slots[k] = slot
    end

    inv.setHotbarSlot( 1 )

    net.Start( "RVR_RequestPlayerUpdate" )
    net.SendToServer()
end

function inv.setHotbarSlot( newIndex )
    if inv.openInventory then return end

    local hotbar = inv.hotbar

    if newIndex == hotbar.selectedSlot then return end

    if newIndex < 1 or newIndex > GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS then return end

    local prevSlot = hotbar.slots[hotbar.selectedSlot]
    if prevSlot then
        prevSlot:SetImageColor( Color( 255, 255, 255 ) )
    end
    hotbar.selectedSlot = newIndex
    hotbar.slots[hotbar.selectedSlot]:SetImageColor( Color( 255, 150, 150 ) )

    net.Start( "RVR_SetHotbarSelected" )
    net.WriteInt( newIndex, 5 )
    net.WriteFloat( RealTime() )
    net.SendToServer()

    -- TODO: play a sound?
end

hook.Add( "InitPostEntity", "RVR_Inventory_hotbarSetup", inv.makeHotbar )

if GAMEMODE then
    inv.makeHotbar()
end

local prevSlotChange = 0

-- I can't find any other way to trigger a hook on scroll
-- This hook is sometimes called more than once per frame, therefore we ignore any duplicate calls
hook.Add( "CreateMove", "RVR_Inventory_hotbarSelect", function()
    if prevSlotChange == RealTime() then return end

    local slotCount = GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS
    local nextSlot = inv.hotbar.selectedSlot

    if input.WasMousePressed( MOUSE_WHEEL_DOWN ) then
        nextSlot = nextSlot + 1
    elseif input.WasMousePressed( MOUSE_WHEEL_UP ) then
        nextSlot = nextSlot - 1
    else
        return
    end

    -- Loop around
    if nextSlot < 1 then nextSlot = slotCount end
    if nextSlot > slotCount then nextSlot = 1 end

    inv.setHotbarSlot( nextSlot )
    prevSlotChange = RealTime()
end )

net.Receive( "RVR_OnItemPickup", function()
    local itemData = net.ReadTable()
    local count = net.ReadInt( 16 )

    -- TODO: Show this infomation somehow
end )

hook.Add( "HUDShouldDraw", "RVR_HideWeapons", function( name )
    if name == "CHudWeaponSelection" then
        return false
    end
end )
