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

Config.PLACEABLES = {
    {
        class = "raft_foundation",
        icon = "rvr/icons/raft_foundation.png"
    },
    {
        class = "raft_platform",
        icon = "rvr/icons/raft_platform.png"
    },
    {
        class = "raft_stairs",
        icon = "rvr/icons/raft_stairs.png"
    },
    {
        class = "raft_wall",
        icon = "rvr/icons/raft_wall.png"
    },
    {
        class = "raft_fence",
        icon = "rvr/icons/raft_fence.png"
    }
}
