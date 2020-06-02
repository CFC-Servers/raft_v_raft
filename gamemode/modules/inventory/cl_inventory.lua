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

function inv.closeInventory()
    if inv.openInventory then
        inv.openInventory:Remove()
        inv.openInventory = nil
    end
    net.Start( "RVR_CloseInventory" )
    net.SendToServer()
end
