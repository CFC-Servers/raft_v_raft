GM.Config = GM.Config or {}
GM.Config.Fish = GM.Config.Fish or {}

local config = GM.Config.Fish
config.tickInterval = 4000 -- How often fish have the chance to spawn in miliseconds
config.spawnRadius = 500
config.waterLevelBias = 20
config.fish = {
    {
        type = "tuna",
        item = "tuna",
        model = "models/rvr/items/tuna.mdl",
        chance = 100,
        health = 20,
        moveDistance = 50,
        moveChance = 75,
        isHostile = false
    }
}