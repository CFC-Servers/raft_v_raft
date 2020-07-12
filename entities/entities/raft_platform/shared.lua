ENT.Base = "raft_piece_base"
ENT.PrintName = "Raft Platform"
ENT.Model = "models/rvr/raft/raft_platform.mdl"
ENT.PreviewPos = Vector( 150, 0, -30 )

DEFINE_BASECLASS("raft_base")

function ENT.IsValidPlacement(piece, dir)
    if piece:GetClass() == "raft_foundation" then
        return dir == Vector(0, 0, 1)
    end

    if piece:GetClass() == "raft_platform" then
        return dir == Vector(0, 0, 1) or BaseClass.IsValidPlacement(piece, dir)
    end
    return false
end

function ENT.GetOffsetDir( piece, dir ) 
    
    if piece:GetClass() == "raft_foundation" and dir.z == 1 then
        dir.z = 0
        return dir
    end
    return dir
end

function ENT:GetRequiredItems()
    return {
        { item = RVR.Items.getItemData( "wood" ), count = 5 },
        { item = RVR.Items.getItemData( "nail" ), count = 5 },
    }
end
