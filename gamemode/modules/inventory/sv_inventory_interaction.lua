RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

util.AddNetworkString( "RVR_Inventory_Open" )
util.AddNetworkString( "RVR_Inventory_Close" )
util.AddNetworkString( "RVR_Inventory_CursorHold" )
util.AddNetworkString( "RVR_Inventory_CursorPut" )
util.AddNetworkString( "RVR_Inventory_CursorDrop" )
util.AddNetworkString( "RVR_Inventory_UpdateSlot" )
util.AddNetworkString( "RVR_Inventory_OnPickup" )
util.AddNetworkString( "RVR_Inventory_DropItem" )
util.AddNetworkString( "RVR_Inventory_RequestPlayerUpdate" )
util.AddNetworkString( "RVR_Inventory_SetHotbarSelected" )

local function removeFunctions( tab )
    for k, v in pairs( tab ) do
        if type( v ) == "function" then
            tab[k] = nil
        end
    end
end

local function getSendableInventory( ent, inventory, isPlayerUpdate )
    local config = GAMEMODE.Config.Inventory

    inventory = table.Copy( inventory )

    if inventory.InventoryType == "Player" then
        local equipmentSlotOffset = config.PLAYER_INVENTORY_SLOTS + config.PLAYER_HOTBAR_SLOTS
        inventory.Inventory[equipmentSlotOffset + 1] = inventory.HeadGear
        inventory.Inventory[equipmentSlotOffset + 2] = inventory.BodyGear
        inventory.Inventory[equipmentSlotOffset + 3] = inventory.FootGear

        if isPlayerUpdate then
            inventory.InventoryType = "PlayerUpdate"
        end
    end

    for k, v in pairs( inventory.Inventory ) do
        v.item = table.Merge( v.item, RVR.Items.getItemData( v.item.type ) )
        removeFunctions( v.item )
    end

    inventory.Ent = ent

    return inventory
end

function inv.notifyItemPickup( ply, item, count )
    local itemTable = table.Copy( RVR.Items.getItemData( item.type ) )
    removeFunctions( itemTable )

    net.Start( "RVR_Inventory_OnPickup" )
        net.WriteTable( itemTable )
        net.WriteUInt( count, 16 )
    net.Send( ply )
end

function inv.notifyItemSlotChange( plys, ent, slotNum, slotData )
    if #plys == 0 then return end

    net.Start( "RVR_Inventory_UpdateSlot" )
        net.WriteEntity( ent )
        net.WriteInt( slotNum, 8 )
        net.WriteBool( tobool( slotData ) )
        if slotData then
            local data = table.Copy( slotData )
            table.Merge( data.item, RVR.Items.getItemData( data.item.type ) )
            removeFunctions( data.item )
            net.WriteTable( data )
        end
    net.Send( plys )
end

function inv.playerOpenInventory( ply, invEnt )
    if ply.RVR_Inventory_Open then return end
    invEnt = invEnt or ply

    local inventoryData = invEnt.RVR_Inventory
    if not inventoryData then return end

    if inventoryData.ActivePlayer then return end

    if hook.Run( "RVR_PreventInventory", ply, invEnt ) then return end

    ply.RVR_Inventory_Open = invEnt

    inventoryData.ActivePlayer = ply

    local isPlayer = invEnt == ply

    net.Start( "RVR_Inventory_Open" )
        net.WriteTable( getSendableInventory( invEnt, inventoryData ) )
        net.WriteBool( isPlayer )
        if not isPlayer then
            net.WriteTable( getSendableInventory( ply, ply.RVR_Inventory ) )
        end
    net.Send( ply )
end

function inv.fullPlayerUpdate( ply )
    net.Start( "RVR_Inventory_Open" )
        net.WriteTable( getSendableInventory( ply, ply.RVR_Inventory, true ) )
        net.WriteBool( true )
    net.Send( ply )
end

net.Receive( "RVR_Inventory_Close", function( len, ply )
    local invEnt = ply.RVR_Inventory_Open
    invEnt.RVR_Inventory.ActivePlayer = nil

    ply.RVR_Inventory_Open = nil

    if not ply.RVR_Inventory.CursorSlot then return end
    local cursorItemData = ply.RVR_Inventory.CursorSlot

    local success, amount = inv.attemptPickupItem( ply, cursorItemData.item, cursorItemData.count )
    if not success then
        cursorItemData.count = cursorItemData.count - amount
        inv.dropItem( ply, -1, -1 )
    end

    ply.RVR_Inventory.CursorSlot = nil
end )

net.Receive( "RVR_Inventory_CursorHold", function( len, ply )
    if not ply.RVR_Inventory then return end
    -- Already holding something
    if ply.RVR_Inventory.CursorSlot then return end

    -- Not in an inventory
    if not ply.RVR_Inventory_Open then return end
    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local count = net.ReadUInt( 8 )

    -- Can't affect an inventory you're not in
    if ent ~= ply and ent ~= ply.RVR_Inventory_Open then return end

    inv.moveItem( ent, ply, position, -1, count )
end )

net.Receive( "RVR_Inventory_CursorPut", function( len, ply )
    if not ply.RVR_Inventory then return end

    local ent = net.ReadEntity()
    local position = net.ReadInt( 8 )
    local count = net.ReadUInt( 8 )

    -- Can't affect an inventory you're not in
    if ent ~= ply and ent ~= ply.RVR_Inventory_Open then return end

    inv.moveItem( ply, ent, -1, position, count )
end )

net.Receive( "RVR_Inventory_CursorDrop", function( len, ply )
    if not ply.RVR_Inventory then return end

    local count = net.ReadUInt( 8 )

    inv.dropItem( ply, -1, count )
end )

net.Receive( "RVR_Inventory_DropItem", function( _, ply )
    if not ply.RVR_Inventory then return end

    local selectedItem = ply.RVR_Inventory.HotbarSelected
    if not selectedItem then return end

    inv.dropItem( ply, selectedItem, ply:KeyDown( IN_DUCK ) and -1 or 1 )
end )

net.Receive( "RVR_Inventory_Open", function( len, ply )
    inv.playerOpenInventory( ply, ply )
end )

net.Receive( "RVR_Inventory_RequestPlayerUpdate", function( len, ply )
    local inventoryData = ply.RVR_Inventory
    if not inventoryData then return end

    inv.fullPlayerUpdate( ply )
end )

net.Receive( "RVR_Inventory_SetHotbarSelected", function( len, ply )
    if not ply.RVR_Inventory then return end

    local newIndex = net.ReadUInt( 4 )
    local clientTime = net.ReadFloat()

    local lastChange = ply.RVR_Inventory.LastHotbarUpdate or 0
    if clientTime < lastChange then return end -- Ensure we only do most recent changes, net messages dont always arrive in order

    ply.RVR_Inventory.LastHotbarUpdate = clientTime

    inv.setSelectedItem( ply, newIndex )
end )
