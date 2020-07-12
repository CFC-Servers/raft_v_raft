ENT.Base = "raft_piece_base"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Wall"
ENT.Model = "models/rvr/raft/wall.mdl"
ENT.IsWall = true
ENT.IsRaft = false
ENT.PreviewPos = Vector( 100, 0, -5 )
ENT.PreviewAngle = Angle( -30, 45, -30 )

function ENT:Initialize()
    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion(false)
    end
end

function ENT:IsValidPlacement(ent,dir)
    return true
end

function ENT.GetOffsetDir( ent, localDir )
    if ent:GetClass() ~= "raft_platform" then
        localDir.z = 0.1
    end
    localDir.z = 1
    return localDir
end

function ENT:GetRequiredItems()
    return {
        { item = RVR.items.getItemData( "wood" ), count = 5 },
        { item = RVR.items.getItemData( "nails" ), count = 5 },
    }
end
