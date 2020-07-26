local possibleItems = GM.Config.Trash.POSSIBLE_ENTITIES
local boxItems =  GM.Config.Trash.SCRAP_BARREL_ITEMS
RVR.Trash = RVR.Trash or {}

local function sorter( a, b ) return a.weight < b.weight end
table.sort( boxItems, sorter )
table.sort( possibleItems, sorter )

for _, item in pairs( possibleItems ) do
    if item.class == "rvr_scrap_barrel" then
        item.afterSpawn = function( ent )
            ent:SetItems( RVR.Trash.getRandomBoxItems( 40 ) )
        end
    end

    if item.itemType then
        item.class = "rvr_dropped_item"
        item.beforeSpawn = function( ent )
            ent:Setup( RVR.Items.getItemData( item.itemType ), item.count or 1 )
        end
    end
end

local function calculateCumulativeWeights( tbl )
    for i = 1, #tbl do
        local item = tbl[i]
        local previous = tbl[i-1]
        local previousWeight = previous and previous.weight or 0

        item.cumWeight = item.weight + previousWeight
    end
end

function RVR.Trash.getRandomWeightedValue( tbl )
    local lastItem = tbl[#tbl]
    if not lastItem.cumWeight then
        calculateCumulativeWeights( tbl )
    end

    local randNum = math.random( 1, lastItem.cumWeight )

    for _, item in next, tbl do
        if randNum <= item.cumWeight then return item end
    end
    return lastItem
end

function RVR.Trash.getRandomBoxItems( amount )
    local items = {}
    for i=1, amount do
        local item = RVR.Trash.getRandomWeightedValue( boxItems )
        table.insert( items, item )
    end

    return items
end

local function getRandomPosition( origin, innerRadius, width )
    local randomAngle = math.random() * 2 * math.pi
    local radius = innerRadius + math.random() * width

    local x, y = math.cos(randomAngle) * radius, math.sin(randomAngle) * radius
    return origin + Vector( x, y, 0 )
end

local function getRandomPly()
    local plys = player.GetHumans()
    return plys[math.random(1, #plys-1)]
end

RVR.Trash.spawnedTrashList = {}
local function createTrash( amount )
    local config = GAMEMODE.Config.Trash
    for i=1, amount do
        local ply = getRandomPly()

        local pos = getRandomPosition( ply:GetPos(), config.SPAWN_RADIUS, config.SPAWN_WIDTH )
        pos.z = RVR.waterSurfaceZ + config.SPAWN_Z_OFFSET

        local item = RVR.Trash.getRandomWeightedValue( possibleItems )

        if util.IsInWorld( pos ) then
            local ent = ents.Create( item.class )
            ent:SetPos( pos )
            if item.beforeSpawn then item.beforeSpawn( ent ) end
            ent:Spawn()
            if item.afterSpawn then item.afterSpawn( ent ) end
            table.insert( RVR.Trash.spawnedTrashList, ent )
        end
    end
end

timer.Create( "RVR_CreateTrash", 5, 0, function()
    local amountPerPlayer = GAMEMODE.Config.Trash.MAX_TRASH_PER_PlAYER
    local amount = amountPerPlayer * #player.GetHumans() - #RVR.Trash.spawnedTrashList 

    amount = math.min( amount, amountPerPlayer )
    createTrash( amount )
end )

local function shouldExist( trash )
    if not IsValid( trash ) then return false end
    return true
end

timer.Create( "RVR_CleanupTrash", 10, 0, function()
    local keysToRemove = {}
    for k, ent in pairs( RVR.Trash.spawnedTrashList ) do
        if not shouldExist( ent ) then
            table.insert( keysToRemove, k )
        end
    end

    for _, key in pairs( keysToRemove ) do
        local ent = table.remove( RVR.Trash.spawnedTrashList, key )
        if IsValid( ent ) then ent:Remove() end
    end
end )
