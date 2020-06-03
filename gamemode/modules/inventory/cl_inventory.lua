RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

include( "cl_itemslot.lua" )
include( "cl_playerinventory.lua" )
include( "cl_boxinventory.lua" )

-- To show it will exist, doesn't actually do anything
inv.openInventory = nil

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
end )

net.Receive( "RVR_UpdateInventorySlot", function()
    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local hasSlotData = net.ReadBool()
    local slotData
    if hasSlotData then
        slotData = net.ReadTable()
    end

    for k, panel in pairs( RVR.ItemSlots or {} ) do
        local slotEnt, slotPos = panel:GetLocationData()
        if slotEnt == ent and slotPos == position then
            -- Found the slot :D
            if slotData then
                panel:SetItemData( slotData.item, slotData.count )
            else
                panel:ClearItemData()
            end

            break
        end
    end
end )

function inv.closeInventory()
    if inv.openInventory then
        inv.openInventory:Remove()
        inv.openInventory = nil
    end

    net.Start( "RVR_CloseInventory" )
    net.SendToServer()
end
