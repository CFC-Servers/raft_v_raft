GM.Config = GM.Config or {}

GM.Config.Trash = {}
local Config = GM.Config.Trash
Config.SPAWN_RADIUS = 1000
Config.SPAWN_WIDTH = 2000
Config.MAX_TRASH_PER_PlAYER = 40
Config.SPAWN_Z_OFFSET = -100
Config.BARREL_DESPAWN_TIME = 300
Config.SCRAP_BARREL_ITEM_AMOUNT = 10

Config.POSSIBLE_ITEMS = {
    {
        itemType = "wood",
        weight = 10,
        minCount = 5,
        maxCount = 15
    },
    {
        class = "rvr_scrap_barrel",
        weight = 2
    },
    {
        itemType = "nail",
        weight = 5,
        minCount = 5,
        maxCount = 15
    }
}

Config.SCRAP_BARREL_ITEMS = {
    { itemType = "wood", weight = 10, minCount = 2, maxCount = 10 },
    { itemType = "nail", weight = 10, minCount = 5, maxCount = 20 }
}
