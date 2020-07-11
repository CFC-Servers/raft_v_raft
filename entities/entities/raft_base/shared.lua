ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "CFC"
ENT.PrintName = ""
ENT.Model = ""
ENT.IsRaft = true

function ENT:SetRaft( raft )
    self:SetRaftID( raft.id )
end

function ENT:GetRaft( raft )
    return RVR.raftLookup[self:GetRaftID()]
end

function ENT.IsValidPlacement(piece, dir)
    if dir.z ~= 0 then return end
    
    if math.abs(dir.x) == math.abs(dir.y) then
        return false
    end

    return true
end

function ENT:GetOffsetDir( dir )
    return dir
end

function ENT:ToRaftDir( dir )
    local copy = Vector( dir.x, dir.y, dir.z )
    
    local rotationOffset = self:GetRaftRotationOffset()

    copy:Rotate( rotationOffset )

    return copy
end

function ENT:ToPieceDir( raftDir )
    local dir = Vector( raftDir.x, raftDir.y, raftDir.z )
    
    local rotationOffset = self:GetRaftRotationOffset()

    dir:Rotate( -rotationOffset )

    return dir
end

function ENT:GetRequiredItems()
    return {
        { item = RVR.items.getItemData( "wood" ), count = 5 },
        { item = RVR.items.getItemData( "nails" ), count = 5 },
    }
end

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "RaftID" )
    self:NetworkVar( "Vector", 0, "RaftGridPosition" )
    self:NetworkVar( "Angle", 0, "RaftRotationOffset" )

    if SERVER then
        self:SetRaftID(0)
        self:SetRaftGridPosition( Vector(0,0,0) )
        self:SetRaftRotationOffset( Angle(0,0,0) )
    end
end