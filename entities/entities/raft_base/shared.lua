ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "CFC"
ENT.PrintName = ""
ENT.Model = ""
ENT.IsRaft = true

local validPlacementDirections = {
    Vector(1, 0, 0),
    Vector(0, 1, 0),
    Vector(-1, 0, 0),
    Vector(0, -1, 0),
}


function ENT:SetRaft( raft )
    self.raft = raft
end

function ENT:GetRaft( raft )
    return self.raft
end

function ENT.IsValidPlacement(piece, dir)
    for _, validDir in pairs( validPlacementDirections ) do
        if dir == validDir then return true end
    end
    
    return false
end

function ENT:GetOffsetDir( dir )
    return dir
end

function ENT:ToRaftDir( dir )
    local copy = Vector( dir.x, dir.y, dir.z )

    self.raftRotationOffset = self.raftRotationOffset or Angle(0, 0, 0)

    copy:Rotate( self.raftRotationOffset )

    return copy
end

function ENT:ToPieceDir( raftDir )
    local dir = Vector( raftDir.x, raftDir.y, raftDir.z )
    self.raftRotationOffset = self.raftRotationOffset or Angle(0, 0, 0)

    dir:Rotate(-self.raftRotationOffset)

    return dir
end

function ENT:GetRequiredItems()
    return {
        { item = RVR.items.getItemData( "wood" ), count = 5 },
        { item = RVR.items.getItemData( "nails" ), count = 5 },
    }
end
