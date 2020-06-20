local function getFirstNonZero( tbl )
    for k, v in pairs( tbl ) do
        if v ~= 0 then return k, v end   
    end
end

function RVR.summonRaft( position )
    local raft = RVR.newRaft()

    local ent = ents.Create( "raft_foundation")
    ent:Spawn() 
    ent:SetPos( position )
    ent:SetRaft( raft )

    raft:AddPiece( Vector( 0, 0, 0 ), ent ) 
    return raft
end

function RVR.expandRaft( piece, data )
    if not piece.IsRaft then return end
    local raft = piece:GetRaft()
    if raft:GetPieceInGrid( piece.RaftGridPosition + data.dir ) then return end

    local size = piece:OBBMaxs() - piece:OBBMins()
    
    _, size = getFirstNonZero( ( size * data.dir ):ToTable() )
    size = math.abs( size ) 

    local Class = baseclass.Get( data.class )

    if not Class.IsValidPlacement( piece, data.dir ) then
        return
    end
    local adjustedDir = Class.GetOffsetDir( piece, data.dir ) 

    local newEnt = ents.Create( data.class )
    newEnt:Spawn()
    newEnt:SetAngles( piece:GetAngles() )
    newEnt:SetPos( piece:LocalToWorld( adjustedDir * size ) )
    
    newEnt:SetRaft( piece:GetRaft() ) 
    raft:AddPiece( piece.RaftGridPosition + data.dir, newEnt )
end
