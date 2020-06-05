RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

util.AddNetworkString( "RVR_OpenInventory" )
util.AddNetworkString( "RVR_CloseInventory" )
util.AddNetworkString( "RVR_CursorHoldItem" )
util.AddNetworkString( "RVR_CursorPutItem" )
util.AddNetworkString( "RVR_DropCursorItem" )
util.AddNetworkString( "RVR_UpdateInventorySlot" )

--TODO:
-- box inventory UI
-- Hotbar

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

    inv.attemptPickupItem( ply, RVR.Items.getItemInstance( "wood" ), 8 )
end

hook.Add( "PlayerInitialSpawn", "RVR_SetupInventory", inv.setupPlayer )

-- Takes a player and table of { item = item, count = count } tables
function inv.playerHasItems( ply, items )
    if not ply.RVR_Inventory then return false end

    for _, invItem in pairs( ply.RVR_Inventory.Inventory ) do
        for k, craftItem in pairs( items ) do
            if inv.canItemsStack( invItem.item, craftItem.item ) then
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

-- Allows for modifying stack checking later - used for checking crafting as well.
function inv.canItemsStack( item1, item2 )
    return item1.type == item2.type and RVR.Items.getItemData( item1.type ).stackable
end

local function notifyItemSlotChange( plys, ent, slotNum, slotData )
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

function inv.setSlot( ent, position, itemData, plysToNotify )
    if not ent.RVR_Inventory then return end

    local isPlayer = type( ent ) == "Player"

    if position < 0 then
        if isPlayer then
            ent.RVR_Inventory.CursorSlot = itemData
        else
            return
        end
    elseif position > 0 and position <= ent.RVR_Inventory.MaxSlots then
        ent.RVR_Inventory.Inventory[position] = itemData
    elseif isPlayer and position > ent.RVR_Inventory.MaxSlots and position < ent.RVR_Inventory.MaxSlots + 3 then
        if position == ent.RVR_Inventory.MaxSlots + 1 then
            ent.RVR_Inventory.HeadGear = itemData
        elseif position == ent.RVR_Inventory.MaxSlots + 2 then
            ent.RVR_Inventory.BodyGear = itemData
        elseif position == ent.RVR_Inventory.MaxSlots + 3 then
            ent.RVR_Inventory.FootGear = itemData
        end
    else
        return
    end

    if plysToNotify then
        notifyItemSlotChange( plysToNotify, ent, position, itemData )
    end
end

function inv.getSlot( ent, position )
    if not ent.RVR_Inventory then return end
    local isPlayer = type( ent ) == "Player"
    local slot

    if isPlayer then
        if position < 0 then
            slot = ent.RVR_Inventory.CursorSlot
        elseif position > ent.RVR_Inventory.MaxSlots and position < ent.RVR_Inventory.MaxSlots + 3 then
            if position == ent.RVR_Inventory.MaxSlots + 1 then
                slot = ent.RVR_Inventory.HeadGear
            elseif position == ent.RVR_Inventory.MaxSlots + 2 then
                slot = ent.RVR_Inventory.BodyGear
            elseif position == ent.RVR_Inventory.MaxSlots + 3 then
                slot = ent.RVR_Inventory.FootGear
            end
        end
    end

    if not slot then
        slot = ent.RVR_Inventory.Inventory[position]
    end

    return slot and table.Copy( slot )
end

function inv.slotCanContain( ent, position, item )
    if not ent.RVR_Inventory then return false end

    local isPlayer = type( ent ) == "Player"
    if isPlayer then
        if position == -1 then return true end

        local itemData = RVR.Items.getItemData( item.type )

        if position == ent.RVR_Inventory.MaxSlots + 1 then
            return tobool( itemData.isHeadGear )
        end
        if position == ent.RVR_Inventory.MaxSlots + 2 then
            return tobool( itemData.isBodyGear )
        end
        if position == ent.RVR_Inventory.MaxSlots + 3 then
            return tobool( itemData.isFootGear )
        end
    end

    return position > 0 and position <= ent.RVR_Inventory.MaxSlots
end

-- returns couldFitAll, amount
function inv.attemptPickupItem( ply, item, count )
    if not ply.RVR_Inventory then return false, 0 end
    count = count or 1
    local originalCount = count

    local itemData = RVR.Items.getItemData( item.type )

    for k = 1, ply.RVR_Inventory.MaxSlots do
        local itemSlotData = inv.getSlot( ply, k )
        -- Can fit more
        if itemSlotData and inv.canItemsStack( itemSlotData.item, item ) and itemSlotData.count < itemData.maxCount then
            local canFit = itemData.maxCount - itemSlotData.count
            if canFit >= count then
                itemSlotData.count = itemSlotData.count + count
                inv.setSlot( ply, k, itemSlotData, { ply } )

                return true, originalCount
            else
                itemSlotData.count = itemSlotData.count + canFit
                inv.setSlot( ply, k, itemSlotData, { ply } )

                count = count - canFit
            end
        end
    end

    for k = 1, ply.RVR_Inventory.MaxSlots do
        local itemSlotData = inv.getSlot( ply, k )
        -- Empty
        if not itemSlotData then
            if count <= itemData.maxCount then
                inv.setSlot( ply, k, { item = item, count = count }, { ply } )
                return true, originalCount
            else
                inv.setSlot( ply, k, { item = item, count = itemData.maxCount }, { ply } )
                count = count - itemData.maxCount
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

-- returns success, error
function inv.moveItem( fromEnt, toEnt, fromPosition, toPosition, count )
    if fromEnt == toEnt and fromPosition == toPosition then return end
    count = count or -1

    local plys = {}
    if type( fromEnt ) == "Player" then
        table.insert( plys, fromEnt )
    end
    if type( toEnt ) == "Player" then
        table.insert( plys, toEnt )
    end

    if not fromEnt.RVR_Inventory or not toEnt.RVR_Inventory then
        return false, "One or more inventories are invalid"
    end

    local fromItem = inv.getSlot( fromEnt, fromPosition )

    if not inv.slotCanContain( toEnt, toPosition, fromItem.item ) then
        return false, "Item cannot be placed here"
    end

    if not fromItem then return false, "No item to move" end

    if count > fromItem.count then
        count = fromItem.count
    end

    local toItem = inv.getSlot( toEnt, toPosition )
    if toItem then
        if not inv.canItemsStack( fromItem.item, toItem.item ) then
            -- Item swapping - Only allow if count is all items
            if count < 0 or count == fromItem.count then
                if not inv.slotCanContain( fromEnt, fromPosition, toItem.item ) then
                    return false, "Item cannot be placed here"
                end
                if not inv.slotCanContain( toEnt, toPosition, fromItem.item ) then
                    return false, "Item cannot be placed here"
                end

                inv.setSlot( fromEnt, fromPosition, toItem, plys )

                inv.setSlot( toEnt, toPosition, fromItem, plys )
            else
                return false, "Cannot swap half a stack"
            end
        else
            -- Item combining
            local toItemData = RVR.Items.getItemData( toItem.item.type )
            count = math.Min( count, toItemData.maxCount - toItem.count )

            if count == 0 then return end

            if count < 0 or count == fromItem.count then
                inv.setSlot( fromEnt, fromPosition, nil, plys )

                toItem.count = toItem.count + fromItem.count
                inv.setSlot( toEnt, toPosition, toItem, plys )
            else
                fromItem.count = fromItem.count - count
                inv.setSlot( fromEnt, fromPosition, fromItem, plys )

                toItem.count = toItem.count + count
                inv.setSlot( toEnt, toPosition, toItem, plys )
            end
        end
    else
        -- Item putting
        if count < 0 or count == fromItem.count then
            inv.setSlot( fromEnt, fromPosition, nil, plys )

            inv.setSlot( toEnt, toPosition, fromItem, plys )
        else
            fromItem.count = fromItem.count - count
            inv.setSlot( fromEnt, fromPosition, fromItem, plys )

            local newItem = { count = count, item = fromItem.item }
            inv.setSlot( toEnt, toPosition, newItem, plys )
        end
    end

    return true
end

function inv.dropItem( ply, position, count )
    count = count or -1

    local itemData = inv.getSlot( ply, position )
    if not itemData then return end

    if count < 0 or count == itemData.count then
        inv.setSlot( ply, position, nil, { ply } )

        count = itemData.count
    else
        itemData.count = itemData.count - count
        inv.setSlot( ply, position, itemData, { ply } )
    end

    local droppedItem = ents.Create( "rvr_dropped_item" )
    if not IsValid( droppedItem ) then return end -- Check whether we successfully made an entity, if not - bail
    droppedItem:SetPos( ply:GetShootPos() + Angle( 0, ply:EyeAngles().yaw, 0 ):Forward() * 20 )
    droppedItem:Setup( RVR.Items.getItemData( itemData.item.type ), count )
    droppedItem:Spawn()

    return droppedItem
end

local function getSendableInventory( inventory )
    local innerInv = {}
    for k, v in pairs( inventory.Inventory ) do
        innerInv[k] = {
            count = v.count,
            item = table.Merge( table.Copy( v.item ), RVR.Items.getItemData( v.item.type ) )
        }
    end

    return {
        InventoryType = inventory.InventoryType,
        Inventory = innerInv
    }
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
