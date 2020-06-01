RVR = RVR or {}
RVR.Inventory = RVR.Inventory or {}

local i = RVR.Inventory
RVR.Inventory.MaxSlots = 20
RVR.Inventory.MaxHotbarSlots = 8

-- Initialize players inventory to empty
function i.setupPlayer( ply )
    ply.RVR_Inventory = {
        Inventory = {
        },
        HotbarSelected = 1,
    }
end

-- Takes a player and table of { item = item, count = count } tables
function i.playerHasItems( ply, items )
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
function i.attemptPickupItem( ply, item, count )
    if not ply.RVR_Inventory then return false, 0 end
    count = count or 1
    local originalCount = count

    for k = 1, RVR.Inventory.MaxHotbarSlots + RVR.Inventory.MaxSlots do
        local itemData = ply.RVR_Inventory.Inventory[i]
        -- Empty
        if not itemData then
            if count <= item.maxCount then
                ply.RVR_Inventory.Inventory[i] = { item = item, count = count }
                return true, originalCount
            else
                ply.RVR_Inventory.Inventory[i] = { item = item, count = item.maxCount }
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
function i.getSelectedItem( ply )
    if not ply.RVR_Inventory then return end

    local itemData = ply.RVR_Inventory.Inventory[ply.RVR_Inventory.HotbarSelected]
    return itemData.item, itemData.count
end

-- returns success, error
function i.moveItem( ply, fromPosition, toPosition, count )
    count = count or -1

    local fromItem = ply.RVR_Inventory.Inventory[fromPosition]

    if not fromItem then return false, "No item to move" end

    if count >= 0 then
        count = math.Min( count, fromItem.count )
    end

    local toItem = ply.RVR_Inventory.Inventory[toPosition]
    if toItem then
        if fromItem.item.type ~= toItem.item.type then
            if count < 0 or count == fromItem.count then
                ply.RVR_Inventory.Inventory[toPosition] = fromItem
                ply.RVR_Inventory.Inventory[fromPosition] = toItem
            else
                return false, "Cannot swap half a stack"
            end
        else
            if count < 0 or count == fromItem.count then
                ply.RVR_Inventory.Inventory[fromPosition] = nil
                toItem.count = toItem.count + fromItem.count
            else
                fromItem.count = fromItem.count - count
                toItem.count = toItem.count + count
            end
        end
    else
        if count < 0 or count == fromItem.count then
            ply.RVR_Inventory.Inventory[fromPosition] = nil
            ply.RVR_Inventory.Inventory[toPosition] = fromItem
        else
            ply.RVR_Inventory.Inventory[toPosition] = { count = count, item = fromItem.item }
            fromItem.count = fromItem.count - count
        end
    end

    return true
end

function i.dropItem( ply, position, count )
    count = count or -1

    local itemData = ply.RVR_Inventory.Inventory[position]
    if not itemData then return end

    if count < 0 or count == itemData.count then
        ply.RVR_Inventory.Inventory[position] = nil
        count = itemData.count
    else
        itemData.count = itemData.count - count
    end

    local droppedItem = ents.Create( "gmod_button" )
    if not IsValid( droppedItem ) then return end -- Check whether we successfully made an entity, if not - bail
    droppedItem:SetPos( ply:GetShootPos() + Angle( 0, ply:EyeAngles().yaw, 0 ):GetForward() * 20 )
    droppedItem:Setup( itemData.item, itemData.count )
    droppedItem:Spawn()

    return droppedItem
end
