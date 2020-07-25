local getRandomBoxItems

local trashItems = {
    { itemType = "wood",  weight = 50 },
    { itemType = "nail", weight = 10 }, -- can they float? sure they can!
    { class = "rvr_scrap_barrel", weight = 10 }
}

local randomBoxItems = {
    { itemType = "wood", weight = 20 },
    { itemType = nil, weight = 50 },
    { itemType = "nail", weight = 40 }
}


local function preProcessTrashItems( tbl )
    table.sort( tbl, function(a, b) return a.weight < b.weight end )
    
    for _, item in pairs( tbl ) do
        if item.class == "rvr_scrap_barrel" then
            item.afterSpawn = function( ent )
                ent:SetItems( getRandomBoxItems( 40 ) )
            end
        end

        if item.itemType then 
            item.class = "rvr_dropped_item" 
            item.beforeSpawn = function( ent )
                ent:Setup( RVR.Items.getItemData( item.itemType ), 10 )
            end
        end
    end
end
preProcessTrashItems( trashItems )

local function calculateCumulativeWeights( tbl )
    for i=1, #tbl do
        local item = tbl[i]
        local previous = tbl[i-1]
        local prevWeight = previous and previous.weight or 0

        item.cumWeight = item.weight + prevWeight
    end
end

local function getRandomItem( tbl )
    local lastItem = tbl[#tbl]
    if not lastItem.cumWeight then calculateCumulativeWeights( tbl ) end

    local randNum = math.random( 1, lastItem.cumWeight )

    for _, item in next, tbl do
        if randNum <= item.cumWeight then return item end
    end
    return lastItem
end

function getRandomBoxItems(amount)
    local items = {}
    for i=1, amount do
        local item = getRandomItem( randomBoxItems )
        
        item.count = math.random(1, 10)
        
        table.insert(items, item)
    end

    return items
end

local function getRandomPosition( origin, innerRadius, width )
    local randomAngle = math.random() * 2 * math.pi
    local radius = innerRadius + math.random() * width

    local x, y = math.cos(randomAngle) * radius, math.sin(randomAngle) * radius
    return origin + Vector( x, y, 0 )
end

function RVR_summonItems( ply )
    for i=1, 100 do
        local pos = getRandomPosition( ply:GetPos(), 1000, 2000 )
        pos.z = RVR.waterSurfaceZ - 100
        local item = getRandomItem( trashItems )

        local ent = ents.Create( item.class ) 
        
        ent:SetPos( pos )
        if item.beforeSpawn then item.beforeSpawn( ent ) end
        ent:Spawn() 
        if item.afterSpawn then item.afterSpawn( ent ) end
          
    end
end

