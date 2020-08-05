GM.Config = GM.Config or {}

GM.Config.Trash = {}
local Config = GM.Config.Trash
Config.SPAWN_RADIUS = 1000
Config.SPAWN_WIDTH = 1500
Config.MAX_TRASH_PER_PlAYER = 15
Config.SPAWN_Z_OFFSET = -100
Config.BARREL_DESPAWN_TIME = 120
Config.SCRAP_BARREL_ITEM_AMOUNT = 5

Config.POSSIBLE_ITEMS = {
    {
        itemType = "wood",
        weight = 10,
        minCount = 1,
        maxCount = 5
    },
    {
        class = "rvr_scrap_barrel",
        weight = 1
    }
}

Config.SCRAP_BARREL_ITEMS = {
    {
        itemType = "wood",
        weight = 5,
        minCount = 5,
        maxCount = 15
    },
    {
        itemType = "nail",
        weight = 5,
        minCount = 5,
        maxCount = 10
    },
    {
        itemType = "dirty_water",
        weight = 5
    },
    {
        itemType = "scrap_metal",
        weight = 3,
        minCount = 1,
        maxCount = 5
    },
    {
        itemType = "cloth",
        weight = 3,
        minCount = 1,
        maxCount = 5
    },
    {
        itemType = "small_rocks",
        weight = 3,
        minCount = 1,
        maxCount = 5
    }
}
