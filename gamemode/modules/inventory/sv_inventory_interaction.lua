RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

util.AddNetworkString( "RVR_OpenInventory" )
util.AddNetworkString( "RVR_CloseInventory" )
util.AddNetworkString( "RVR_CursorHoldItem" )
util.AddNetworkString( "RVR_CursorPutItem" )
util.AddNetworkString( "RVR_DropCursorItem" )
util.AddNetworkString( "RVR_UpdateInventorySlot" )

local function getSendableInventory( inventory )
    inventory = table.Copy( inventory )
    for k, v in pairs( inventory.Inventory ) do
        v.item = table.Merge( v.item, RVR.Items.getItemData( v.item.type ) )
    end

    if inventory.InventoryType == "Player" then
        local equipmentSlotOffset = GM.Config.Inventory.PLAYER_INVENTORY_SLOTS + GM.Config.Inventory.PLAYER_HOTBAR_SLOTS
        inventory.Inventory[equipmentSlotOffset + 1] = inventory.HeadGear
        inventory.Inventory[equipmentSlotOffset + 2] = inventory.BodyGear
        inventory.Inventory[equipmentSlotOffset + 3] = inventory.FootGear
    end

    return inventory
end

function inv.notifyItemSlotChange( plys, ent, slotNum, slotData )
    if #plys == 0 then return end

    net.Start( "RVR_UpdateInventorySlot" )
    net.WriteEntity( ent )
    net.WriteInt( slotNum, 8 )
    net.WriteBool( tobool( slotData ) )
    if slotData then
        local data = table.Copy( slotData )
        table.Merge( data.item, RVR.Items.getItemData( data.item.type ) )
        net.WriteTable( data )
    end
    net.Send( plys )
end

function inv.playerOpenInventory( ply, invEnt )
    if ply.RVR_OpenInventory then
        return
    end
    invEnt = invEnt or ply

    local inventoryData = invEnt.RVR_Inventory
    if not inventoryData then return end

    if inventoryData.ActivePlayer then return end

    if hook.Run( "RVR_PreventInventory", ply, invEnt ) then return end

    ply.RVR_OpenInventory = invEnt

    inventoryData.ActivePlayer = ply

    local isPlayer = invEnt == ply

    net.Start( "RVR_OpenInventory" )
    net.WriteTable( getSendableInventory( inventoryData ) )
    net.WriteBool( isPlayer )
    if not isPlayer then
        net.WriteTable( getSendableInventory( ply.RVR_Inventory ) )
    end
    net.Send( ply )
end

net.Receive( "RVR_CloseInventory", function( len, ply )
    local invEnt = ply.RVR_OpenInventory
    invEnt.RVR_Inventory.ActivePlayer = nil

    ply.RVR_OpenInventory = nil

    if not ply.RVR_Inventory.CursorSlot then return end
    local cursorItemData = ply.RVR_Inventory.CursorSlot

    local success, amount = inv.attemptPickupItem( ply, cursorItemData.item, cursorItemData.count )
    if not success then
        cursorItemData.count = cursorItemData.count - amount
        inv.dropItem( ply, -1, -1 )
    end

    ply.RVR_Inventory.CursorSlot = nil
end )

net.Receive( "RVR_CursorHoldItem", function( len, ply )
    if not ply.RVR_Inventory then return end
    -- Already holding something
    if ply.RVR_Inventory.CursorSlot then return end

    -- Not in an inventory
    if not ply.RVR_OpenInventory then return end
    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local count = net.ReadInt( 8 )

    -- Can't affect an inventory you're not in
    if ent ~= ply and ent ~= ply.RVR_OpenInventory then
        return
    end

    inv.moveItem( ent, ply, position, -1, count )
end )

net.Receive( "RVR_CursorPutItem", function( len, ply )
    if not ply.RVR_Inventory then return end

    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local count = net.ReadInt( 8 )

    -- Can't affect an inventory you're not in
    if ent ~= ply and ent ~= ply.RVR_OpenInventory then
        return
    end

    inv.moveItem( ply, ent, -1, position, count )
end )

net.Receive( "RVR_DropCursorItem", function( len, ply )
    if not ply.RVR_Inventory then return end

    local count = net.ReadInt( 8 )

    inv.dropItem( ply, -1, count )
end )

net.Receive( "RVR_OpenInventory", function( len, ply )
    inv.playerOpenInventory( ply, ply )
end )