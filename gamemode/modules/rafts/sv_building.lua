RVR.Builder = {} or RVR.Builder
local builder = RVR.Builder

hook.Add( "RVR_Party_PartyCreated", "RVR_Raft_createRaft", function( partyData )
    local raft = RVR.Builder.createRaft( Vector( 0, 0, RVR.waterSurfaceZ ) )

    raft:SetPartyID( partyData.id )

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
