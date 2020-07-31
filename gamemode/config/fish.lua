GM.Config = GM.Config or {}
GM.Config.Fish = GM.Config.Fish or {}

local config = GM.Config.Fish
config.FISH_TIMER_DELAY = 10
config.SPAWN_RADIUS = 1000
config.DESPAWN_RADIUS = 1500
config.WATER_LEVEL_BIAS = 20
config.FISH_PER_PLAYER = 10
config.SCARED_DISTANCE = 200

config.FISH = {
    {
        type = "tuna",
        item = "tuna",
        model = "models/rvr/items/tuna.mdl",
        chance = 100,
        health = 20,
        moveDistance = 50,
        moveChance = 75,
        isHostile = false
    },
    {
        type = "horse_mackerel",
        item = "horse_mackerel",
        model = "models/rvr/items/horse_mackerel.mdl",
        chance = 100,
        health = 10,
        moveDistance = 25,
        moveChance = 75,
        isHostile = false
    }
}
