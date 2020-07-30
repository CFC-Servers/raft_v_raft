RVR.Items = RVR.Items or {}
local items = RVR.Items

function items.getItemData( itemType )
    for _, itemData in pairs( items.items ) do
        if itemData.type == itemType then return itemData end
    end
end

-- Wrapper for now, allows adding metadata to item instances later
function items.getItemInstance( itemType )
    local itemData = items.getItemData( itemType )
    if not itemData then
        error( "Item type " .. itemType .. " does not exist" )
    end

    local instance = {
        type = itemType
    }

    if itemData.hasDurability then
        instance.durability = itemData.maxDurability
    end

    return instance
end

-- Item structure in README
-- TODO: Update item descriptions
items.items = {
    {
        type = "wood",
        displayName = "Wood",
        description = "A soggy plank of wood found in the ocean.",
        maxCount = 10,
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
        maxCount = 25,
        model = "models/rvr/items/nail.mdl",
        icon = "materials/rvr/items/nail.png",
        stackable = true,
        worldModelOffset = Vector( -2, 1, 3 )
    },
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
        type = "gun",
        displayName = "Gun",
        description = "G U N",
        swep = "weapon_pistol",
        icon = "materials/icon16/cross.png",
        stackable = false
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
    {
        type = "raft_builder",
        displayName = "Raft Builder",
        description = "Build rafts uwu",
        model = "models/weapons/w_crowbar.mdl",
        swep = "raft_builder",
        stackable = false,
        icon = "materials/rvr/items/raft_builder.png"
    },
    {
        type = "spear",
        displayName = "Spear",
        description = "For hittin' stuff. uwu",
        swep = "rvr_spear",
        stackable = false,
        icon = "materials/rvr/items/wooden_spear.png",
        hasDurability = true,
        maxDurability = 150,
        durabilityUse = 10,
        durabilityUseRandomRange = 10
    },
    {
        type = "tape",
        displayName = "Tape",
        description = "For repairin' stuff. uwu",
        swep = "rvr_tape",
        stackable = false,
        icon = "materials/rvr/items/ducttape.png",
        hasDurability = true,
        maxDurability = 150,
        durabilityUse = 10,
        durabilityUseRandomRange = 10
    },
    {
        type = "binoculars",
        displayName = "Binoculars",
        description = "For lookin' at stuff. uwu",
        swep = "rvr_binoculars",
        stackable = false,
        model = "models/rvr/items/binoculars.mdl",
        icon = "materials/rvr/items/binoculars.png"
    },
    {
        type = "sword",
        displayName = "Sword",
        description = "For hittin' stuff. uwu",
        swep = "rvr_sword",
        stackable = false,
        icon = "materials/rvr/items/sword.png",
        hasDurability = true,
        maxDurability = 150,
        durabilityUse = 5,
        durabilityUseRandomRange = 6
    },
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
    {
        type = "physgun",
        displayName = "Physics gun",
        description = "Gmod physics gun, how did you get this?!",
        stackable = false,
        swep = "weapon_physgun",
        icon = "materials/icon16/shield.png"
    },
    {
        type  = "bigger_gun",
        displayName = "AR2",
        description = "pew pew!",
        swep = "weapon_ar2",
        stackable = false,
        icon = "materials/icon16/cancel.png"
    }
}

local config = GM.Config.Hunger

for k, item in pairs( items.items ) do
    if item.consumable and ( item.food or item.water or item.health ) then
        function item:onConsume( ply )
            if self.food then
                ply:AddFood( self.food )
            end

            if self.water then
                ply:AddWater( self.water )
            end

            if self.health then
                if self.health < 0 then
                    ply:TakeDamage( -self.health, ply, ply )
                else
                    ply:SetHealth( math.Clamp( ply:Health() + self.health, 0, 100 ) )
                end
            end
        end

        function item:canConsume( ply )
            if self.food and ply:GetFood() <= config.MAX_FOOD - 1 then
                return true
            end

            if self.water and ply:GetWater() <= config.MAX_WATER - 1 then
                return true
            end

            if self.health and ( self.health < 0 or ply:Health() <= 99 ) then
                return true
            end

            return false
        end
    end
end

for _, item in pairs( items.items ) do
    if item.model then
        util.PrecacheModel( item.model )
    end
    item.maxCount = item.maxCount or 1
end
