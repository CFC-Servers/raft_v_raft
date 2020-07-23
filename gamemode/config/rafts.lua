GM.Config = GM.Config or {}
GM.Config.Rafts = {}

local Config = GM.Config.Rafts
Config.BUILDING_REQUIREMENTS = {
    raft_piece_wall = { -- default raft piece requirements
        wood = 10,
        nail = 10
    },
    raft_foundation = {
        wood = 15,
        nail = 10
    },
    raft_platform = {
        wood = 20,
        nail = 10
    },
    raft_stairs = {
        wood = 25,
        nail = 15
    },
    raft_fence = {
        wood = 10,
        nail = 5
    },
    raft_wall = {
        wood = 20,
        nail = 10
    }
}

Config.RAFT_VERTICAL_OFFSET = 10

-- Raft creation time scales with the square of this number, double it, and the creation time quadruples
Config.SPAWN_GRID_SIZE = 100

-- How many spawn points to try for a new raft
Config.SPAWN_CANDIDATE_BATCH_SIZE = 30

-- The distance at which other rafts no longer affect the score of a candidate
Config.SPAWN_EFFECT_CUTOFF_DISTANCE = 1500

Config.SPAWNPOINT_PARTS = {
    raft_foundation = true,
    raft_platform = true
}

Config.Map = {}

-- Used for spawning rafts
Config.Map["rvr_water"] = {
    -- This should be set to the minimum corner in x and y
    MAP_MIN = Vector( -15000, -15000 ),

    -- This should be set to the maximum corner in x and y
    MAP_MAX = Vector( 15000, 15000 )
}
