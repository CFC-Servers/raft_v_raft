RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

include( "cl_itemslot.lua" )
include( "cl_playerinventory.lua" )
include( "cl_boxinventory.lua" )

local cursorSlotSize = 60

net.Receive( "RVR_OpenInventory", function()
    local inventory = net.ReadTable()
    local isSelf = net.ReadBool()

    local plyInventory
    if not isSelf then
        plyInventory = net.ReadTable()
    end

    local invType = inventory.InventoryType

    if invType == "Player" then
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

hook.Add( "PlayerBindPress", "RVR_OpenInventory", function( ply, bind )
    if bind == "+menu" then
        inv.openInventoryKey = input.GetKeyCode( input.LookupBinding( "+menu" ) )
        net.Start( "RVR_OpenInventory" )
        net.SendToServer()
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
    surface.SetMaterial( inv.cursorItemMaterial ) -- If you use Material, cache it!
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
