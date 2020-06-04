RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

util.AddNetworkString( "RVR_OpenInventory" )
util.AddNetworkString( "RVR_CloseInventory" )
util.AddNetworkString( "RVR_CursorHoldItem" )
util.AddNetworkString( "RVR_CursorPutItem" )
util.AddNetworkString( "RVR_UpdateInventorySlot" )

-- Initialize players inventory to empty
function inv.setupPlayer( ply )
    local GM = GAMEMODE

    ply.RVR_Inventory = {
        Inventory = {},
        MaxSlots = GM.Config.Inventory.PLAYER_HOTBAR_SLOTS + GM.Config.Inventory.PLAYER_INVENTORY_SLOTS,
        HotbarSelected = 1,
        InventoryType = "Player",
        CursorSlot = nil
    }

    inv.attemptPickupItem( ply, RVR.items[1] )
end

hook.Add( "PlayerInitialSpawn", "RVR_SetupInventory", inv.setupPlayer )

-- Takes a player and table of { item = item, count = count } tables
function inv.playerHasItems( ply, items )
    if not ply.RVR_Inventory then return false end

    for _, invItem in pairs( ply.RVR_Inventory.Inventory ) do
        for k, craftItem in pairs( items ) do
            if invItem.item.type == craftItem.item.type then
                craftItem.count = craftItem.count - invItem.count
                if craftItem.count <= 0 then
                    table.remove( items, k )
                    break
                end
            end
        end
        if #items == 0 then
            return true
        end
    end

    return false
end

-- returns couldFitAll, amount
function inv.attemptPickupItem( ply, item, count )
    if not ply.RVR_Inventory then return false, 0 end
    count = count or 1
    local originalCount = count

    for k = 1, ply.RVR_Inventory.MaxSlots do
        local itemData = ply.RVR_Inventory.Inventory[k]
        -- Empty
        if not itemData then
            if count <= item.maxCount then
                ply.RVR_Inventory.Inventory[k] = { item = item, count = count }
                return true, originalCount
            else
                ply.RVR_Inventory.Inventory[k] = { item = item, count = item.maxCount }
                count = count - item.maxCount
            end
        end

        -- Can fit more
        if itemData.item.type == item.type and itemData.count < item.maxCount then
            local canFit = item.maxCount - itemData.count
            if canFit >= count then
                itemData.count = itemData.count + count
                return true, originalCount
            else
                itemData.count = itemData.count + canFit
                count = count - canFit
            end
        end
    end

    return false, originalCount - count
end

-- returns item, count
function inv.getSelectedItem( ply )
    if not ply.RVR_Inventory then return end

    local itemData = ply.RVR_Inventory.Inventory[ply.RVR_Inventory.HotbarSelected]
    return itemData.item, itemData.count
end

function inv.setSelectedItem( ply, idx )
    local GM = GAMEMODE
    if not ply.RVR_Inventory then return end
    idx = math.Clamp( idx, 1, GM.Config.Inventory.PLAYER_INVENTORY_SLOTS )

    ply.RVR_Inventory.HotbarSelected = idx
end

local function notifyItemSlotChange( plys, ent, slotNum, slotData )
    if #plys == 0 then return end

    net.Start( "RVR_UpdateInventorySlot" )
    net.WriteEntity( ent )
    net.WriteInt( slotNum, 8 )
    net.WriteBool( tobool( slotData ) )
    if slotData then
        net.WriteTable( slotData )
    end
    net.Send( plys )
end

-- returns success, error
-- TODO: Add support for cursor slot (position = -1)
-- TODO: Make this call notifyItemSlotChange if fromEnt or toEnt are players
-- TODO: Make this adhere to item.maxCount
function inv.moveItem( fromEnt, toEnt, fromPosition, toPosition, count )
    count = count or -1

    local plys = {}
    if type( fromEnt ) == "Player" then
        table.insert( plys, fromEnt )
    end
    if type( toEnt ) == "Player" then
        table.insert( plys, toEnt )
    end

    local fromInventoryData = fromEnt.RVR_Inventory
    local toInventoryData = toEnt.RVR_Inventory

    if not fromInventoryData or not toInventoryData then
        return false, "One or more inventories are invalid"
    end

    if fromPosition < 1 or fromPosition > fromInventoryData.MaxSlots then
        return false, "Invalid slot position"
    end

    if toPosition < 1 or toPosition > toInventoryData.MaxSlots then
        return false, "Invalid slot position"
    end

    local fromItem = fromInventoryData.Inventory[fromPosition]

    if not fromItem then return false, "No item to move" end

    if count > fromItem.count then
        count = fromItem.count
    end

    -- TODO: refactor this to look nicer
    local toItem = toInventoryData.Inventory[toPosition]
    if toItem then
        if fromItem.item.type ~= toItem.item.type then
            -- Item swapping - Only allow if count is all items
            if count < 0 or count == fromItem.count then
                toInventoryData.Inventory[toPosition] = fromItem
                notifyItemSlotChange( plys, toEnt, toPosition, fromItem )

                fromInventoryData.Inventory[fromPosition] = toItem
                notifyItemSlotChange( plys, fromEnt, fromPosition, toItem )
            else
                return false, "Cannot swap half a stack"
            end
        else
            -- Item combining
            if count < 0 or count == fromItem.count then
                fromInventoryData.Inventory[fromPosition] = nil
                notifyItemSlotChange( plys, fromEnt, fromPosition, nil )

                toItem.count = toItem.count + fromItem.count
                notifyItemSlotChange( plys, toEnt, toPosition, toItem )
            else
                fromItem.count = fromItem.count - count
                notifyItemSlotChange( plys, fromEnt, fromPosition, fromItem )

                toItem.count = toItem.count + count
                notifyItemSlotChange( plys, toEnt, toPosition, toItem )
            end
        end
    else
        -- Item putting
        if count < 0 or count == fromItem.count then
            fromInventoryData.Inventory[fromPosition] = nil
            notifyItemSlotChange( plys, fromEnt, fromPosition, nil )

            toInventoryData.Inventory[toPosition] = fromItem
            notifyItemSlotChange( plys, toEnt, toPosition, fromItem )
        else
            local newItem = { count = count, item = fromItem.item }
            toInventoryData.Inventory[toPosition] = newItem
            notifyItemSlotChange( plys, toEnt, toPosition, newItem )

            fromItem.count = fromItem.count - count
            notifyItemSlotChange( plys, fromEnt, fromPosition, fromItem )
        end
    end

    return true
end

function inv.dropItem( ply, position, count )
    count = count or -1

    local itemData = ply.RVR_Inventory.Inventory[position]
    if not itemData then return end

    if count < 0 or count == itemData.count then
        ply.RVR_Inventory.Inventory[position] = nil
        count = itemData.count
    else
        itemData.count = itemData.count - count
    end

    local droppedItem = ents.Create( "rvr_dropped_item" )
    if not IsValid( droppedItem ) then return end -- Check whether we successfully made an entity, if not - bail
    droppedItem:SetPos( ply:GetShootPos() + Angle( 0, ply:EyeAngles().yaw, 0 ):Forward() * 20 )
    droppedItem:Setup( itemData.item, itemData.count )
    droppedItem:Spawn()

    return droppedItem
end

-- TODO: Reject if opened by another player
-- Store activePlayer on the inventory
function inv.playerOpenInventory( ply, invEnt )
    if ply.RVR_OpenInventory then
        return
    end
    invEnt = invEnt or ply

    local inventoryData = invEnt.RVR_Inventory
    if not inventoryData then return end

    if hook.Run( "RVR_PreventInventory", ply, invEnt ) then return end

    ply.RVR_OpenInventory = invEnt

    local isPlayer = invEnt == ply

    net.Start( "RVR_OpenInventory" )
    net.WriteTable( inventoryData )
    net.WriteBool( isPlayer )
    if not isPlayer then
        net.WriteTable( ply.RVR_Inventory )
    end
    net.Send( ply )
end

-- TODO: Try put CursorSlot item into inv, else drop it
net.Receive( "RVR_CloseInventory", function( len, ply )
    ply.RVR_OpenInventory = nil
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

hook.Add( "KeyPress", "RVR_OpenInventory", function( ply, key )
    -- TODO: change to menu key
    if key == IN_ZOOM then
        inv.playerOpenInventory( ply, ply )
    end
end )
