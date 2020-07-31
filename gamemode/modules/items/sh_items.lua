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

items.items = GM.Config.Items.itemDefinitions

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
