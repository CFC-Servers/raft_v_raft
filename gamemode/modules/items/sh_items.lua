--[[ item structure:
{
    type = (string) unique name for item
    displayName = (string) Name used in menus
    maxCount = (int) max stack size in inventories
    model = (string) dropped item + held item model
    icon = (string) inventory icon
    isHeadGear = (bool) can this be equipped in head slot
    isBodyGear = (bool) can this be equipped in body slot
    isFootGear = (bool) can this be equipped in foot slot
    stackable = (bool) can this be stacked in inventory or as dropped item
]]

RVR.Items = RVR.Items or {}
local items = RVR.Items

function items.getItemData( itemType )
    for k, v in pairs( items.items ) do
        if v.type == itemType then return v end
    end
end

-- Wrapper for now, allows adding metadata to item instances later
function items.getItemInstance( itemType )
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
        icon = "materials/icons/wood-tmp.png",
        isHeadGear = true,
        stackable = true,
    }
}
