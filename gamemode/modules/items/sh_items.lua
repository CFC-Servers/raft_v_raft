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
items.items = {
    {
        type = "wood",
        displayName = "Wood",
        maxCount = 10,
        model = "models/rvr/items/item_plank.mdl",
        icon = "materials/rvr/items/wood.png",
        stackable = true,
    },
    {
        type = "nail",
        displayName = "Nail",
        maxCount = 25,
        model = "models/rvr/items/item_nail.mdl",
        icon = "materials/rvr/items/nail.png",
        stackable = true,
    },
}

local config = GM.Config.Hunger

for k, item in pairs( items.items ) do
    if item.consumable and ( item.food or item.water or item.health ) then
        function item.onConsume( ply )
            if item.food then
                ply:AddFood( item.food )
            end

            if item.water then
                ply:AddWater( item.water )
            end

            if item.health then
                ply:SetHealth( math.Clamp( ply:Health() + item.health, 0, 100 ) )
            end
        end

        function item.canConsume( ply )
            if item.food and ply:GetFood() <= config.MAX_FOOD - 1 then
                return true
            end

            if item.water and ply:GetWater() <= config.MAX_WATER - 1 then
                return true
            end

            if item.health and ply:Health() <= 99 then
                return true
            end

            return false
        end
    end
end
