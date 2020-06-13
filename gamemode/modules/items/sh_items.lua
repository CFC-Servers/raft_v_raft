RVR.Items = RVR.Items or {}
local items = RVR.Items

function items.getItemData( itemType )
    for _, itemData in pairs( items.items ) do
        if itemData.type == itemType then return itemData end
    end
end

-- Wrapper for now, allows adding metadata to item instances later
function items.getItemInstance( itemType )
    if not items.getItemData( itemType ) then
        error( "Item type " .. itemType .. " does not exist" )
    end

    return {
        type = itemType
    }
end

items.items = {
    {
        type = "wood",
        displayName = "Wood",
        maxCount = 10,
        model = "models/Gibs/wood_gib01b.mdl",
        icon = "materials/rvr/items/wood.png",
        stackable = true,
    },
    {
        type = "nail",
        displayName = "Nail",
        maxCount = 25,
        model = "models/rvr/items/item_nail.mdl",
        icon = "materials/rvr/items/nail.png",
        stackable = true,
    }
}
