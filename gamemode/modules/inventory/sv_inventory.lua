RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

-- Players have special cases for the slot number of their inventory
-- A slot number of -1 indicates the players cursor slot, this is remove when an inventory is closed
-- A slot number of MaxSlot + 1, 2, 3 are for the 3 equipment slots: head, body and foot

-- Initialize players inventory to empty
function inv.setupPlayer( ply )
    local config = GAMEMODE.Config.Inventory

    ply.RVR_Inventory = {
        Inventory = {},
        MaxSlots = config.PLAYER_HOTBAR_SLOTS + config.PLAYER_INVENTORY_SLOTS,
        HotbarSelected = 1,
        InventoryType = "Player",
        CursorSlot = nil,
        HeadGear = nil,
        BodyGear = nil,
        FootGear = nil,
    }
end

hook.Add( "PlayerInitialSpawn", "RVR_SetupInventory", inv.setupPlayer )

function inv.clearInventory( ent )
    if not ent.RVR_Inventory then return end

    ent.RVR_Inventory.Inventory = {}

    if ent:IsPlayer() then
        ent.RVR_Inventory.CursorSlot = nil
        ent.RVR_Inventory.HeadGear = nil
        ent.RVR_Inventory.BodyGear = nil
        ent.RVR_Inventory.FootGear = nil
        ent.RVR_Inventory.HotbarSelected = 1

        inv.fullPlayerUpdate( ent )
    end
end

function inv.isEmpty( ent )
    local entInv = ent.RVR_Inventory
    if not entInv then return true end

    if not table.IsEmpty( entInv.Inventory ) then return false end

    if ent:IsPlayer() then
        if entInv.CursorSlot or entInv.HeadGear or entInv.BodyGear or entInv.FootGear then
            return false
        end
    end

    return true
end

function inv.tryTakeItems( ent, items )
    local inventory = ent.RVR_Inventory

    local invCopy = table.Copy( inventory.Inventory )
    items = table.Copy( items )

    local changes = {}

    for invPos, invItem in pairs( invCopy ) do
        for k, craftItem in pairs( items ) do
            if invItem.item.type == craftItem.item.type then
                local used = math.Min( invItem.count, craftItem.count )
                craftItem.count = craftItem.count - used

                invItem.count = invItem.count - used
                if invItem.count == 0 then
                    invCopy[invPos] = nil
                end
                table.insert( changes, { pos = invPos, itemData = invCopy[invPos] } )

                if craftItem.count == 0 then
                    table.remove( items, k )
                    break
                end
            end
        end

        if #items == 0 then
            for k, change in pairs( changes ) do
                inv.setSlot( ent, change.pos, change.itemData, type( ent ) == "Player" and { ent } )
            end
            return true
        end
    end

    return false, items
end

function inv.setSlot( ent, position, itemData, plysToNotify )
    local inventory = ent.RVR_Inventory
    if not inventory then return end

    local isPlayer = type( ent ) == "Player"

    local typeChanged = false

    if position < 0 then
        if isPlayer then
            ent.RVR_Inventory.CursorSlot = itemData
        else
            return
        end
    elseif position > 0 and position <= inventory.MaxSlots then
        if inventory.Inventory[position] and itemData then
            typeChanged = inventory.Inventory[position].item.type ~= itemData.item.type
        else
            typeChanged = tobool( itemData ) ~= tobool( inventory.Inventory[position] )
        end
        inventory.Inventory[position] = itemData
    elseif isPlayer and position > inventory.MaxSlots and position < inventory.MaxSlots + 3 then
        if position == inventory.MaxSlots + 1 then
            inventory.HeadGear = itemData
        elseif position == inventory.MaxSlots + 2 then
            inventory.BodyGear = itemData
        elseif position == inventory.MaxSlots + 3 then
            inventory.FootGear = itemData
        end
    else
        return
    end

    if isPlayer and position == inventory.HotbarSelected and typeChanged then
        -- Refresh weapon
        inv.setSelectedItem( ent, inventory.HotbarSelected )
    end

    if plysToNotify then
        inv.notifyItemSlotChange( plysToNotify, ent, position, itemData )
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

function inv.consumeInSlot( ent, position, count )
    local slotData = RVR.Inventory.getSlot( ent, position )

    if not slotData then
        return false, "No items in slot"
    end

    if slotData.count < count then
        return false, "Not enough items in slot"
    end

    slotData.count = slotData.count - count
    if slotData.count == 0 then
        slotData = nil
    end

    local plys
    if type( ent ) == "Player" then
        plys = { ent }
    end

    RVR.Inventory.setSlot( ent, position, slotData, plys )
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
function inv.attemptPickupItem( ent, item, count )
    if not ent.RVR_Inventory then return false, 0 end
    count = count or 1
    local originalCount = count

    if ent.RVR_Inventory.PreventAdding then return false, 0 end

    local isPlayer = ent:IsPlayer()
    local plys
    if isPlayer then
        plys = { ent }
    end

    local itemData = RVR.Items.getItemData( item.type )

    for k = 1, ent.RVR_Inventory.MaxSlots do
        local itemSlotData = inv.getSlot( ent, k )
        -- Can fit more
        if itemSlotData and inv.canItemsStack( itemSlotData.item, item ) and itemSlotData.count < itemData.maxCount then
            local canFit = itemData.maxCount - itemSlotData.count
            if canFit >= count then
                itemSlotData.count = itemSlotData.count + count
                inv.setSlot( ent, k, itemSlotData, plys )

                if isPlayer then
                    inv.notifyItemPickup( ent, item, originalCount )
                end
                return true, originalCount
            else
                itemSlotData.count = itemSlotData.count + canFit
                inv.setSlot( ent, k, itemSlotData, plys )

                count = count - canFit
            end
        end
    end

    for k = 1, ent.RVR_Inventory.MaxSlots do
        local itemSlotData = inv.getSlot( ent, k )
        -- Empty
        if not itemSlotData then
            if count <= itemData.maxCount then
                inv.setSlot( ent, k, { item = item, count = count }, plys )

                if isPlayer then
                    inv.notifyItemPickup( ent, item, originalCount )
                end
                return true, originalCount
            else
                inv.setSlot( ent, k, { item = item, count = itemData.maxCount }, plys )
                count = count - itemData.maxCount
            end
        end
    end

    local amountPickedup = originalCount - count

    if amountPickedup > 0 and isPlayer then
        inv.notifyItemPickup( ent, item, amountPickedup )
    end

    return false, amountPickedup
end

-- returns item, count
function inv.getSelectedItem( ply )
    if not ply.RVR_Inventory then return end

    local itemData = ply.RVR_Inventory.Inventory[ply.RVR_Inventory.HotbarSelected]
    if not itemData then return end

    return itemData.item, itemData.count
end

function inv.setSelectedItem( ply, idx )
    local config = GAMEMODE.Config.Inventory
    if not ply.RVR_Inventory then return end
    idx = math.Clamp( idx, 1, config.PLAYER_INVENTORY_SLOTS )

    if hook.Run( "RVR_Inventory_CanChangeHotbarSelected", ply, idx ) == false then return end

    ply.RVR_Inventory.HotbarSelected = idx

    ply:StripWeapons()

    local itemSlotData = ply.RVR_Inventory.Inventory[idx]

    local wep
    if itemSlotData then
        local itemData = RVR.Items.getItemData( itemSlotData.item.type )

        if itemData.swep then
            wep = ply:Give( itemData.swep )
        else
            wep = ply:Give( "rvr_held_item" )
            wep:SetItemData( itemData )
        end
    else
        -- TODO: remove when rvr_hands implemented
        do return end
        wep = ply:Give( "rvr_hands" )
    end

    ply:SetActiveWeapon( wep )
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

    if not fromItem then return false, "No item to move" end

    if not inv.slotCanContain( toEnt, toPosition, fromItem.item ) then
        return false, "Item cannot be placed here"
    end

    if toEnt.RVR_Inventory.PreventAdding then
        return false, "This inventory cannot have items added to it"
    end

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
    if not IsValid( droppedItem ) then return end
    droppedItem:SetPos( ply:GetShootPos() + Angle( 0, ply:EyeAngles().yaw, 0 ):Forward() * 20 )
    droppedItem:Setup( RVR.Items.getItemData( itemData.item.type ), count )
    droppedItem:Spawn()

    return droppedItem
end
