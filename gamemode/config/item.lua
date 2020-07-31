GM.Config.Items = GM.Config.Items or {}
local config = GM.Config.Items

config.itemDefinitions = {
    -- Ingredients
    {
        type = "wood",
        displayName = "Wood",
        description = "A soggy plank of wood found in the ocean.",
        maxCount = 30,
        model = "models/rvr/items/plank.mdl",
        icon = "materials/rvr/items/wood.png",
        stackable = true,
        worldModelOffset = Vector( -2, -2, 0 ),
        worldModelAng = Angle( 90, 90, 0 )
    },
    {
        type = "nail",
        displayName = "Nail",
        description = "Careful! It's sharp!",
        maxCount = 40,
        model = "models/rvr/items/nail.mdl",
        icon = "materials/rvr/items/nail.png",
        stackable = true,
        worldModelOffset = Vector( -2, 1, 3 )
    },
    {
        type = "small_rocks",
        displayName = "Small rocks",
        description = "A handful of smaller rocks",
        maxCount = 25,
        model = "models/rvr/items/rocks.mdl",
        icon = "materials/rvr/items/rocks.png",
        stackable = true,
        viewModelOffset = Vector( 5, -1, -3 ),
        worldModelOffset = Vector( 0, 0, 2 ),
    },
    {
        type = "big_rock",
        displayName = "Big rock",
        description = "A big ol' rock, might be a little heavy",
        maxCount = 10,
        model = "models/rvr/items/big_rock.mdl",
        icon = "materials/rvr/items/big_rock.png",
        stackable = true,
        viewModelOffset = Vector( 5, -1, -3 ),
        worldModelOffset = Vector( 3, 0, 5 ),
    },
    {
        type = "straw",
        displayName = "Straw",
        description = "A plastic straw that you found in the ocean... Wonder how that got there?",
        maxCount = 30,
        model = "models/rvr/items/straw.mdl",
        icon = "materials/rvr/items/straw.png",
        stackable = true,
        viewModelOffset = Vector( 8, -19, -7 ),
        viewModelAng = Angle( 0, 90, 0 ),
        worldModelOffset = Vector( -2, 1, 4 )
    },
    {
        type = "cloth",
        displayName = "Cloth",
        description = "A little scrap of cloth",
        maxCount = 20,
        model = "models/props_junk/garbage_newspaper001a.mdl",
        material = "models/debug/debugwhite",
        color = Color( 220, 220, 190 ),
        icon = "materials/rvr/items/cloth.png",
        stackable = true
    },
    {
        type = "rope",
        displayName = "Rope",
        description = "A bundle of rope made from cloth scraps",
        maxCount = 10,
        model = "models/rvr/items/rope.mdl",
        icon = "materials/rvr/items/rope.png",
        stackable = true,
        viewModelOffset = Vector( 10, 8, 15 ),
        viewModelAng = Angle( 0, 0, 90 ),
    },
    {
        type = "iron",
        displayName = "Iron bar",
        description = "A somewhat poorly casted bar of iron",
        maxCount = 5,
        model = "models/rvr/items/iron.mdl",
        icon = "materials/rvr/items/iron.png",
        stackable = true,
        viewModelOffset = Vector( -20, 1, -4 ),
        viewModelAng = Angle( 0, -90, 0 ),
        worldModelOffset = Vector( 3, 0, 3 ),
        worldModelAng = Angle( 90, 90, 0 )
    },
    {
        type = "scrap_metal",
        displayName = "Scrap metal",
        description = "An assortment of random scraps of metal",
        maxCount = 10,
        model = "models/rvr/items/scrap_metal.mdl",
        icon = "materials/rvr/items/scrap_metal.png",
        stackable = true,
        viewModelOffset = Vector( -13, -25, -5 ),
        viewModelAng = Angle( 0, 180, 0 ),
        worldModelOffset = Vector( 0, 2, 0 ),
        worldModelAng = Angle( -90, 180, 0 )
    },

    -- Food
    {
        type = "tuna",
        displayName = "Tuna",
        description = "A living tuna, eating it would not only make you a monster, but also hurt you!",
        maxCount = 5,
        model = "models/rvr/items/tuna.mdl",
        icon = "materials/rvr/items/tuna.png",
        stackable = true,
        consumable = true,
        food = 10,
        health = -5,
        worldModelOffset = Vector( -1, 2, -8 ),
        worldModelAng = Angle( -90, 0, 90 )
    },
    {
        type = "cooked_tuna",
        displayName = "Cooked Tuna",
        description = "A cooked tuna, yum?",
        maxCount = 5,
        model = "models/rvr/items/tuna_cooked.mdl",
        icon = "materials/rvr/items/cooked_tuna.png",
        stackable = true,
        consumable = true,
        food = 30,
        worldModelOffset = Vector( -1, 2, -8 ),
        worldModelAng = Angle( -90, 0, 90 )
    },
    {
        type = "horse_mackerel",
        displayName = "Horse Mackerel",
        description = "A living horse mackerel, eating it would not only make you a monster, but also hurt you!",
        maxCount = 10,
        model = "models/rvr/items/horse_mackerel.mdl",
        icon = "materials/rvr/items/horse_mackerel.png",
        stackable = true,
        consumable = true,
        food = 5,
        health = -5,
        worldModelOffset = Vector( -1, 1.5, -3 ),
        worldModelAng = Angle( -90, 0, 90 )
    },
    {
        type = "cooked_horse_mackerel",
        displayName = "Cooked Horse Mackerel",
        description = "A cooked horse mackerel, yum?",
        maxCount = 10,
        model = "models/rvr/items/horse_mackerel_cooked.mdl",
        icon = "materials/rvr/items/cooked_horse_mackerel.png",
        stackable = true,
        consumable = true,
        food = 15,
        worldModelOffset = Vector( -1, 1.5, -3 ),
        worldModelAng = Angle( -90, 0, 90 )
    },
    {
        type = "water",
        displayName = "Water bottle",
        description = "A non-brand bottle of water, how convenient!",
        maxCount = 5,
        model = "models/rvr/items/bottle.mdl",
        icon = "materials/rvr/items/water_bottle.png",
        stackable = true,
        consumable = true,
        water = 60,
        viewModelOffset = Vector( -2, 5, -9 ),
        viewModelAng = Angle( 0, -15, 0 ),
        worldModelOffset = Vector( -2, 1, 7 )
    },
    {
        type = "dirty_water",
        displayName = "Dirty Water bottle",
        description = "This water is filthy, I wouldn't drink it if I were you!",
        maxCount = 5,
        model = "models/rvr/items/bottle.mdl",
        icon = "materials/rvr/items/dirty_waterbottle.png",
        stackable = true,
        consumable = true,
        water = -5,
        health = -10,
        viewModelOffset = Vector( -2, 5, -9 ),
        viewModelAng = Angle( 0, -15, 0 )
    },

    -- Health
    {
        type = "bandage",
        displayName = "Makeshift bandage",
        description = "It ain't pretty, but it might help",
        maxCount = 10,
        model = "models/rvr/items/bandage.mdl",
        icon = "materials/rvr/items/bandage.png",
        stackable = true,
        consumable = true,
        health = 10
    },
    {
        type = "medkit",
        displayName = "Makeshift medkit",
        description = "Not exactly hospital quality, but much better than a bandage",
        maxCount = 5,
        model = "models/rvr/items/pills.mdl",
        icon = "materials/rvr/items/pills.png",
        stackable = true,
        consumable = true,
        health = 50
    },

    -- Tools
    {
        type = "raft_builder",
        displayName = "Raft Builder",
        description = "Build rafts with various items found in the ocean!",
        model = "models/weapons/w_crowbar.mdl",
        swep = "raft_builder",
        maxCount = 1,
        stackable = false,
        icon = "materials/rvr/items/raft_builder.png"
    },
    {
        type = "tape",
        displayName = "Tape",
        description = "Fixes up raft parts",
        swep = "rvr_repair_tool",
        icon = "materials/rvr/items/duct_tape.png",
        model = "models/rvr/items/tape.mdl",
        stackable = false,
        hasDurability = true,
        maxDurability = 1000,
        durabilityUse = 1
    },
    {
        type = "paddle",
        displayName = "Paddle",
        description = "Move your raft in the direction that you paddle!",
        stackable = false,
        swep = "rvr_paddle",
        icon = "materials/rvr/items/wooden_paddle.png"
    },

    -- Placables
    {
        type = "storage_box",
        displayName = "Storage Box",
        description = "Store all your items!",
        maxCount = 1,
        model = "models/props_junk/wood_crate001a.mdl",
        icon = "materials/rvr/items/storage_box.png",
        placeable = true,
        placeableClass = "rvr_storage",
        viewModelOffset = Vector( 30, 50, -9 )
    },
    {
        type = "storage_box_small",
        displayName = "Small Storage Box",
        description = "Store all your items!",
        maxCount = 1,
        model = "models/props_junk/cardboard_box002b.mdl",
        icon = "materials/rvr/items/storage_box_small.png",
        placeable = true,
        placeableClass = "rvr_storage_small",
        viewModelOffset = Vector( 30, 50, -9 )
    },
    {
        type = "storage_box_large",
        displayName = "Large Storage Box",
        description = "Store all your items!",
        maxCount = 1,
        model = "models/props_junk/wood_crate002a.mdl",
        icon = "materials/rvr/items/storage_box_large.png",
        placeable = true,
        placeableClass = "rvr_storage_large",
        viewModelOffset = Vector( 50, 50, -9 )
    },
    {
        type = "workbench",
        displayName = "Work Bench",
        description = "Crafting.. woah!",
        maxCount = 1,
        model = "models/rvr/props/workbench.mdl",
        icon = "materials/rvr/items/workbench.png",
        placeable = true,
        placeableClass = "rvr_crafter",
        viewModelOffset = Vector( 30, 60, -39 ),
        viewModelAng = Angle( 0, -40, 0 )
    },
    {
        type = "water_purifier",
        displayName = "Water Purifier",
        description = "Makes water from air? is this magick?",
        maxCount = 1,
        model = "models/props_borealis/bluebarrel001.mdl",
        icon = "materials/rvr/items/water_purifier.png",
        placeable = true,
        placeableClass = "rvr_water_purifier",
        viewModelOffset = Vector( 30, 50, -30 )
    },
    {
        type = "grill",
        displayName = "Grill",
        description = "Cook your food. Or eat it, rawr~",
        maxCount = 1,
        model = "models/rvr/props/grill.mdl",
        icon = "materials/rvr/items/grill.png",
        placeable = true,
        placeableClass = "rvr_grill",
        viewModelOffset = Vector( 10, 40, -20 ),
        viewModelAng = Angle( 0, -40, 0 )
    },

    -- Admin
    {
        type = "gun",
        displayName = "Gun",
        description = "G U N",
        swep = "weapon_pistol",
        icon = "materials/icon16/cross.png",
        stackable = false
    },
    {
        type = "physgun",
        displayName = "Physics gun",
        description = "Gmod physics gun, how did you get this?!",
        stackable = false,
        swep = "weapon_physgun",
        icon = "materials/icon16/shield.png"
    }
}
