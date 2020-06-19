RVR.Inventory = RVR.Inventory or {}

local inv = RVR.Inventory

-- Takes an inventory and table of { item = item, count = count } tables
-- Returns success, itemsMissing
function inv.checkItems( inventory, items )
    items = table.Copy( items )

    for invPos, invItem in pairs( inventory.Inventory ) do
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

    return false, items
end
