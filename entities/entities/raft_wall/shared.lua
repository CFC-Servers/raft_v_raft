ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Wall"
ENT.Model = "models/rvr/raft/raft_wall.mdl"
ENT.IsRaft = true
ENT.PreviewPos = Vector( 100, 0, -5 )
ENT.PreviewAngle = Angle( -30, 45, -30 )

function ENT:GetRequiredItems()
    return {
        { item = RVR.items.getItemData( "wood" ), count = 5 },
        { item = RVR.items.getItemData( "nails" ), count = 5 },
    }
end
