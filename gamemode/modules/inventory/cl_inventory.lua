RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

include( "cl_itemslot.lua" )
include( "cl_playerinventory.lua" )
include( "cl_boxinventory.lua" )

local cursorSlotSize = 60

net.Receive( "RVR_Inventory_Open", function()
    local inventory = net.ReadTable()
    local isSelf = net.ReadBool()

    local plyInventory = inventory
    if not isSelf then
        plyInventory = net.ReadTable()
    end

    -- Update hotbar slots for any inventory open
    for k = 1, GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS do
        local data = plyInventory.Inventory[k]
        if data then
            inv.hotbar.slots[k]:SetItemData( data.item, data.count )
        else
            inv.hotbar.slots[k]:ClearItemData()
        end
    end

    inv.plyInventoryCache = table.Copy( plyInventory )
    hook.Run( "RVR_InventoryCacheUpdate", inv.plyInventoryCache )

    local invType = inventory.InventoryType

    if invType == "PlayerUpdate" then
        -- Inventory open of type "PlayerUpdate" should not trigger a UI element, it is simply a full hotbar update
        return
    elseif invType == "Player" then
        inv.openInventory = inv.openPlayerInventory( inventory )
    elseif invType == "Box" then
        inv.openInventory = inv.openBoxInventory( inventory, plyInventory )
    end

    inv.enableCursorSlot()

    -- Add key bind hook to close inventory via Use or Menu
    function inv.openInventory:OnKeyCodePressed( key )
        local menuKey = input.GetKeyCode( input.LookupBinding( "+menu" ) )
        local useKey = input.GetKeyCode( input.LookupBinding( "+use" ) )
        if key == menuKey or key == useKey then
            inv.closeInventory()
        end
    end
end )

-- Updates an existing RVR_ItemSlot element with new data
net.Receive( "RVR_Inventory_UpdateSlot", function()
    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local hasSlotData = net.ReadBool()
    local slotData
    if hasSlotData then
        slotData = net.ReadTable()
    end

    -- Update to the LocalPlayers cursor slot
    -- Since this is rendered directly to HUD, and not a VGUI element, it must be handled differently
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

    if ent == LocalPlayer() and inv.plyInventoryCache then
        inv.plyInventoryCache.Inventory[position] = slotData
        hook.Run( "RVR_InventoryCacheUpdate", inv.plyInventoryCache )
    end
end )

hook.Add( "PlayerBindPress", "RVR_Inventory", function( _, bind, pressed )
    if not pressed then return end

    if bind == "+menu" then
        -- Open own inventory
        net.Start( "RVR_Inventory_Open" )
        net.SendToServer()

        return true
    elseif string.StartWith( bind, "slot" ) then
        -- Set selected slot
        local slotNum = tonumber( string.sub( bind, 5 ) )
        if not slotNum then return end

        inv.setHotbarSlot( slotNum )

        return true
    end
end )

function inv.closeInventory()
    if inv.openInventory then
        inv.openInventory:Remove()
        inv.openInventory = nil
    end

    inv.disableCursorSlot()
    net.Start( "RVR_Inventory_Close" )
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

function inv.selfHasItems( items )
    return inv.checkItems( inv.plyInventoryCache, items, false )
end

function inv.selfGetItemCount( itemType )
    return inv.getItemCount( inv.plyInventoryCache, itemType )
end

function inv.selfCanFitItem( item, count )
    return inv.canFitItem( inv.plyInventoryCache, item, count )
end

-- Render the cursor slot
hook.Add( "PostRenderVGUI", "RVR_Inventory_DrawCursorItem", function()
    if not inv.showCursorItem or not inv.cursorItemMaterial then return end

    local mx, my = gui.MousePos()
    local x, y = mx - cursorSlotSize / 2, my - cursorSlotSize / 2

    -- Item icon
    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( inv.cursorItemMaterial )
    surface.DrawTexturedRect( x, y, cursorSlotSize, cursorSlotSize )

    if inv.cursorItemCount <= 1 then return end

    -- Item count
    local countText = tostring( inv.cursorItemCount )
    surface.SetFont( "DermaLarge" )
    local tw, th = surface.GetTextSize( countText )
    local tx = x + cursorSlotSize - tw - 1
    local ty = y + cursorSlotSize - th + 5

    surface.SetTextColor( 200, 200, 200 )
    surface.SetTextPos( tx, ty )
    surface.DrawText( countText )
end )

-- Handle dropping items by clickout outside of openInventory frame
hook.Add( "GUIMousePressed", "RVR_Inventory_DropItem", function( code, aimVector )
    if not inv.openInventory then return end
    local mx, my = gui.MousePos()

    local panelX, panelY = inv.openInventory:GetPos()
    local panelW, panelH = inv.openInventory:GetSize()

    local onBorderX = mx < panelX or mx > panelX + panelW
    local onBorderY = my < panelY or my > panelY + panelH

    if not onBorderX and not onBorderY then return end

    local item, count = inv.getCursorItemData()
    -- Don't drop if no item
    if not item then return end

    -- Right clicking only drops one item
    if code == MOUSE_RIGHT then count = 1 end

    net.Start( "RVR_Inventory_CursorDrop" )
        net.WriteUInt( count, 8 )
    net.SendToServer()
end )

local hotbarBackgroundMat = Material( "rvr/backgrounds/player_hotbar_background.png" )

-- Just builds the frame then makes some RVR_ItemSlots, nothing special
function inv.makeHotbar()
    local config = GAMEMODE.Config.Inventory

    inv.hotbar = inv.hotbar or {}
    local hotbar = inv.hotbar

    if hotbar.frame then hotbar.frame:Remove() end
    local w, h = ScrW(), ScrH()

    local slotCount = config.PLAYER_HOTBAR_SLOTS
    local innerHotbarWidth = w * 0.45

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

        local slot = vgui.Create( "RVR_ItemSlot", hotbar.frame )
        slot:SetSize( slotSize, slotSize )
        slot:SetPos( offsetX + ( k - 1 ) * slotSize, offsetY )
        slot:SetLocationData( LocalPlayer(), k )

        hotbar.slots[k] = slot
    end

    inv.setHotbarSlot( 1 )

    net.Start( "RVR_Inventory_RequestPlayerUpdate" )
    net.SendToServer()
end

-- Set slot local
function inv.setHotbarSlot( newIndex )
    local hotbar = inv.hotbar

    if newIndex == hotbar.selectedSlot then return end

    if newIndex < 1 or newIndex > GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS then return end

    if hook.Run( "RVR_Inventory_CanChangeHotbarSelected", LocalPlayer(), newIndex ) == false then return end

    local prevSlot = hotbar.slots[hotbar.selectedSlot]
    if prevSlot then
        prevSlot:SetImageColor( Color( 255, 255, 255 ) )
    end
    hotbar.selectedSlot = newIndex
    hotbar.slots[hotbar.selectedSlot]:SetImageColor( Color( 255, 150, 150 ) )

    net.Start( "RVR_Inventory_SetHotbarSelected" )
        net.WriteUInt( newIndex, 4 )
        net.WriteFloat( RealTime() )
    net.SendToServer()

    chat.PlaySound()
end

hook.Add( "InitPostEntity", "RVR_Inventory_HotbarSetup", inv.makeHotbar )
hook.Add( "OnScreenSizeChanged", "RVR_Inventory_HotbarSetup", inv.makeHotbar )

if GAMEMODE then
    inv.makeHotbar()
end

local prevSlotChange = 0

-- I can't find any other way to trigger a hook on scroll
-- This hook is sometimes called more than once per frame, therefore we ignore any duplicate calls
-- This hook is also called when UI elements are on screen, so have to ignore those calls
hook.Add( "CreateMove", "RVR_Inventory_HotbarSelect", function()
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

    if inv.openInventory or gui.IsGameUIVisible() then return end

    if hook.Run( "RVR_Inventory_HotbarCanScroll" ) == false then return end

    -- Loop around
    if nextSlot < 1 then nextSlot = slotCount end
    if nextSlot > slotCount then nextSlot = 1 end

    inv.setHotbarSlot( nextSlot )
    prevSlotChange = RealTime()
end )

-- Hide default weapon selection
hook.Add( "HUDShouldDraw", "RVR_Inventory_HideWeapons", function( name )
    if name == "CHudWeaponSelection" then
        return false
    end
end )
