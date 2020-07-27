RVR.Fish = RVR.Fish or {}
local config = GM.Config.Fish
local nextTick = nextTick or CurTime()
local millisecondsToSeconds = 1000

local function canSpawnFish( zPos )
    local waterZ = RVR.waterSurfaceZ - config.waterLevelBias
    local spawnRadius = config.spawnRadius

    if zPos - waterZ > spawnRadius then return false end

    return true
end

local function randomWaterPos( ply )
    local spawnRadius = config.spawnRadius
    local pos = ply:LocalToWorld( VectorRand( -spawnRadius, spawnRadius ) )
    local waterZ = RVR.waterSurfaceZ - config.waterLevelBias

    pos.z = math.Clamp( pos.z, -math.huge, waterZ )

    return pos
end

hook.Add( "Tick", "RVR_Fish_Think", function()
    local theTime = CurTime()

    if theTime >= nextTick then
        for _, fishData in pairs( config.fish ) do
            for _, ply in pairs( player.GetAll() ) do
                local shouldSpawn = math.random( 1, 100 ) <= fishData.chance

                if shouldSpawn and canSpawnFish( ply:GetPos().z ) then
                    local pos = randomWaterPos( ply )
                    local ang = Angle( 0, math.random( -180, 180 ), 0 )

                    local newFish = ents.Create( fishData.isHostile and "rvr_hostile_fish_base" or "rvr_nuetral_fish_base" )
                    newFish:SetPos( pos )
                    newFish:SetAngles( ang )
                    newFish:Setup( fishData )
                    newFish:Spawn()
                end
            end
        end

        nextTick = theTime + ( config.tickInterval / millisecondsToSeconds )
    end
end )
