RVR.Items = RVR.Items or {}
local items = RVR.Items

function items.getItemData( itemType )
    for _, itemData in pairs( items.items ) do
        if itemData.type == itemType then return itemData end
    end
end

-- Wrapper for now, allows adding metadata to item instances later
function items.getItemInstance( itemType )
    if not items.getItemData( itemType ) then
        error( "Item type " .. itemType .. " does not exist" )
    end

    return {
        type = itemType
    }
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
    },
    {
        type = "nail",
        displayName = "Nail",
        description = "Careful! It's sharp!",
        maxCount = 25,
        model = "models/rvr/items/nail.mdl",
        icon = "materials/rvr/items/nail.png",
        stackable = true,
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
    },
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
    util.PrecacheModel( item.model )
end
