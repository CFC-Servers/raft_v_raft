RVR.Trash = RVR.Trash or {}
local config = GM.Config.Trash

local getRandomBoxItems

local function sorter( a, b ) return a.weight < b.weight end
table.sort( config.SCRAP_BARREL_ITEMS, sorter )
table.sort( config.POSSIBLE_ITEMS, sorter )

for _, item in pairs( config.POSSIBLE_ITEMS ) do
    if item.class == "rvr_scrap_barrel" then
        item.afterSpawn = function( ent )
            ent:SetItems( getRandomBoxItems( 40 ) )
        end
    end

    if item.itemType then
        item.class = "rvr_dropped_item"
        item.beforeSpawn = function( ent )
            local count = math.random( item.mincount or 1, item.maxcount  or 1 )
            ent:Setup( RVR.Items.getItemData( item.itemType ), count )
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

local function getRandomWeightedValue( tbl )
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


function getRandomBoxItems( amount )
    local items = {}
    for i=1, amount do
        local item = getRandomWeightedValue( config.SCRAP_BARREL_ITEMS )
        local count = math.random( item.mincount or 1, item.maxcount or 1 )
        table.insert( items, { itemType = item.itemType, count = count } )
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
    local alivePlayers = {}
    for _, ply in pairs( plys ) do
        if ply:Alive() then
            alivePlayers[#plys+1] = ply
        end
    end
    if #alivePlayers == 0 then return nil end

    return plys[math.random(1, #plys-1)]
end


RVR.Trash.spawnedTrashList = {}

local function createTrashForPlayer( ply )
    local pos = getRandomPosition( ply:GetPos(), config.SPAWN_RADIUS, config.SPAWN_WIDTH )
    pos.z = RVR.waterSurfaceZ + config.SPAWN_Z_OFFSET

    if not util.IsInWorld( pos ) then return end

    local item = getRandomWeightedValue( config.POSSIBLE_ITEMS )
    if not item.class then return  end

    local ent = ents.Create( item.class )
    ent:SetPos( pos )

    if item.beforeSpawn then item.beforeSpawn( ent ) end
    ent:Spawn()
    if item.afterSpawn then item.afterSpawn( ent ) end

    table.insert( RVR.Trash.spawnedTrashList, ent )
end

local function createTrash( amount )
    for i=1, amount do
        local ply = getRandomPly()

        if not ply then break end

        createTrashForPlayer( ply )
    end
end

timer.Create( "RVR_CreateTrash", 5, 0, function()
    local amountPerPlayer = config.MAX_TRASH_PER_PlAYER
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
