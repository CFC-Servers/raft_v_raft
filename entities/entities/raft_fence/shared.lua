ENT.Base = "raft_wall"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Short Wall"
ENT.Model = "models/rvr/raft/fence.mdl"

function ENT:GetRequiredItems()
    return {
        { item = RVR.Items.getItemData( "wood" ), count = 5 },
        { item = RVR.Items.getItemData( "nails" ), count = 5 },
    }
end
