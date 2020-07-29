RVR.Fish = RVR.Fish or {}
RVR.Fish.spawnedFish = {}

local config = GM.Config.Fish
local nextTick = nextTick or CurTime()
local millisecondsToSeconds = 1000

local function randomWaterPos( ply )
    local spawnRadius = config.SPAWN_RADIUS
    local pos = ply:LocalToWorld( VectorRand( -spawnRadius, spawnRadius ) )
    local waterZ = RVR.waterSurfaceZ - config.WATER_LEVEL_BIAS

    pos.z = math.Clamp( pos.z, -math.huge, waterZ )

    return pos
end

local function spawnFishForPlayer( ply )
    for _, fishData in pairs( config.FISH ) do
        local shouldSpawn = math.random( 1, 100 ) <= fishData.chance

        if shouldSpawn then
            local pos = randomWaterPos( ply )
            local ang = Angle( 0, math.random( -180, 180 ), 0 )

            local className = fishData.isHostile and "rvr_hostile_fish_base" or "rvr_neutral_fish_base"
            local newFish = ents.Create( className )
            newFish:SetPos( pos )
            newFish:SetAngles( ang )
            newFish:Setup( fishData )
            newFish:Spawn()
            table.insert( RVR.Fish.spawnedFish, newFish )
        end
    end
end

timer.Create( "RVR_FishSpawning", config.FISH_TIMER_DELAY, 0, function()
    if config.FISH_PER_PLAYER * #player.GetHumans() < #RVR.Fish.spawnedFish then
        return
    end

    for _, ply  in pairs( player.GetHumans() ) do
        if ply:Alive() then spawnFishForPlayer( ply ) end
    end
end )

timer.Create( "RVR_CleanupFish", 10, 0, function()
    local keysToRemove = {}
    for k, ent in pairs( RVR.Fish.spawnedFish ) do
        if not IsValid( ent ) then
            table.insert( keysToRemove, k )
        end
    end

    for _, key in pairs( keysToRemove ) do
        local ent = table.remove( RVR.Fish.spawnedFish, key )
        if IsValid( ent ) then ent:Remove() end
    end
end )
