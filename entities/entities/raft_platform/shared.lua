ENT.Base = "raft_piece_base"
ENT.PrintName = "Platform"
ENT.Model = "models/rvr/raft/platform.mdl"
ENT.PreviewPos = Vector( 150, 0, -30 )
ENT.DefaultMass = 20

DEFINE_BASECLASS( "raft_piece_base" )

function ENT.IsValidPlacement( piece, dir )
    if piece:GetClass() == "raft_foundation" then
        return dir == Vector( 0, 0, 1 )
    end

    if piece:GetClass() == "raft_platform" then
        return dir == Vector( 0, 0, 1 ) or BaseClass.IsValidPlacement( piece, dir )
    end
    return false
end

function ENT.GetOffsetDir( piece, dir )
    if piece:GetClass() == "raft_foundation" and dir.z == 1 then
        dir.z = 0
    end
    return dir
end

function ENT:GetWallOrigin()
    return Vector( 0, 0, 91 )
end
