RVR.Builder = {} or RVR.Builder
local builder = RVR.Builder

function builder.getNewRaftPosition()
    local config = GAMEMODE.Config.Rafts
    local mapConfig = GAMEMODE.Config.Rafts.Map[game.GetMap()]

    -- Fallback to rvr_water if non existant
    if not mapConfig then
        mapConfig = GAMEMODE.Config.Rafts.Map["rvr_water"]
        print( "[RVR] Warning! Missing map size definitions for " .. game.GetMap() .. " in rafts config." )
    end

    local raftPoses = builder.getRaftPositions()

    local bestSpawn = Vector( 0, 0, RVR.waterSurfaceZ + config.RAFT_VERTICAL_OFFSET )
    local bestSpawnSqrDist = 0

    local w = mapConfig.MAP_MAX.x - mapConfig.MAP_MIN.x
    local h = mapConfig.MAP_MAX.y - mapConfig.MAP_MIN.y

    local spawnEffectCutoffSqr = config.SPAWN_EFFECT_CUTOFF_DISTANCE ^ 2

    for i = 1, config.SPAWN_CANDIDATE_BATCH_SIZE do
        local gridX = math.random( 0, config.SPAWN_GRID_SIZE )
        local gridY = math.random( 0, config.SPAWN_GRID_SIZE )

        -- World position from grid pos
        local x = mapConfig.MAP_MIN.x + w * ( gridX / config.SPAWN_GRID_SIZE )
        local y = mapConfig.MAP_MIN.y + h * ( gridY / config.SPAWN_GRID_SIZE )

        local pos = Vector( x, y, RVR.waterSurfaceZ + config.RAFT_VERTICAL_OFFSET )

        local totalSqrDist = 0
        for _, raftPos in pairs( raftPoses ) do
            totalSqrDist = totalSqrDist + raftPos:DistToSqr( pos )
        end

        -- Clamp totalSqrDist to spawnEffectCutoffSqr
        if totalSqrDist > spawnEffectCutoffSqr then
            totalSqrDist = spawnEffectCutoffSqr
        end

        if totalSqrDist > bestSpawnSqrDist then
            bestSpawnSqrDist = totalSqrDist
            bestSpawn = pos
        end
    end

    return bestSpawn
end

function builder.getRaftPositions()
    local config = GAMEMODE.Config.Rafts

    local out = {}
    for _, raft in pairs( RVR.raftLookup ) do
        local pos = raft:GetAveragePosition()
        pos.z = RVR.waterSurfaceZ + config.RAFT_VERTICAL_OFFSET
        table.insert( out, pos )
    end

    return out
end

hook.Add( "RVR_Party_PartyCreated", "RVR_Raft_createRaft", function( partyData )
    local raft = RVR.Builder.createRaft( builder.getNewRaftPosition() )

    raft:SetPartyID( partyData.id )

    builder.expandRaft( raft:GetPiece( Vector( 0, 0, 0 ) ), "raft_foundation", Vector( 1, 0, 0 ))
    builder.expandRaft( raft:GetPiece( Vector( 0, 0, 0 ) ), "raft_foundation", Vector( 0, 1, 0 ), Angle( 0, 180, 0 ) )
    builder.expandRaft( raft:GetPiece( Vector( 1, 0, 0 ) ), "raft_foundation", Vector( 0, 1, 0 ))

    partyData.raft = raft
end )

hook.Add( "RVR_Party_PartyRemoved", "RVR_Raft_removeRaft", function( partyData )
    if not partyData.raft then return end

    if partyData.raft then
        partyData.raft:Remove()
    end
end )

function builder.createRaft( position )
    local raft = RVR.newRaft()

    local ent = ents.Create( "raft_foundation" )
    ent:Spawn()
    ent:SetPos( position )
    ent:SetRaft( raft )

    raft:AddPiece( Vector( 0, 0, 0 ), ent )
    return raft
end

-- returns an error
function builder.expandRaft( piece, class, dir, rotation )
    if not piece.IsRaft then return end
    rotation = rotation or Angle( 0, 0, 0 )

    local raft = piece:GetRaft()
    local localDir = piece:ToPieceDir( dir )

    local targetPosition = raft:GetPosition( piece ) + dir
    if raft:GetPiece( targetPosition ) then
        return nil, "Target position contains a raft piece"
    end

    local size = RVR.getSizeFromDirection( piece, localDir )
    local ClassTable = baseclass.Get( class )

    if not ClassTable.IsValidPlacement( piece, dir ) then
        return nil, "This placement direction is not valid"
    end

    localDir = ClassTable.GetOffsetDir( piece, localDir )

    local newEnt = ents.Create( class )
    newEnt:Spawn()
    newEnt:SetAngles( piece:GetAngles() - piece:GetRaftRotationOffset() + rotation )
    newEnt:SetPos( piece:LocalToWorld( localDir * size ) )
    newEnt:SetRaftRotationOffset( rotation )
    newEnt:SetRaft( piece:GetRaft() )
    raft:AddPiece( raft:GetPosition( piece ) + dir, newEnt )
    return newEnt, nil
end

function builder.placeWall( piece, class, yaw )
    local pos = piece:GetWallOrigin()
    piece.walls = piece.walls or {}

    if IsValid( piece.walls[yaw] ) then return nil, "Wall already exists" end

    local newEnt = ents.Create( class )
    newEnt:Spawn()
    newEnt:SetPos( piece:LocalToWorld( pos ) )
    newEnt:SetAngles( piece:LocalToWorldAngles( Angle( 0, yaw, 0 ) ) )
    piece.walls[yaw] = newEnt
    return newEnt
end
