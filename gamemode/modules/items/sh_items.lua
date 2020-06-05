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
]]

RVR.items = {
    {
        type = "wood",
        displayName = "Wood",
        maxCount = 10,
        model = "models/Gibs/wood_gib01b.mdl",
        icon = "materials/icons/player_inventory_background.png",
    }
}
