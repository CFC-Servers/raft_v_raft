RVR.Fish = RVR.Fish or {}
RVR.Fish.spawnedFish = RVR.Fish.spawnedFish or {}

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

            local className = "rvr_neutral_fish_base"
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
    if config.FISH_PER_PLAYER * #player.GetHumans() <= #RVR.Fish.spawnedFish then
        return
    end

    for _, ply  in pairs( player.GetHumans() ) do
        if ply:Alive() then spawnFishForPlayer( ply ) end
    end
end )

timer.Create( "RVR_CleanupFish", 10, 0, function()
    local spawnedFish = RVR.Fish.spawnedFish
    for i = #spawnedFish, 1, -1 do
        local ent = spawnedFish[i]
        if not IsValid( ent ) then
            table.remove( spawnedFish, i )
        end
    end
end )
