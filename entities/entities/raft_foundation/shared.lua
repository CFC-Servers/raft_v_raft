ENT.Base = "raft_piece_base"
ENT.PrintName = "Foundation"
ENT.Model = "models/rvr/raft/foundation.mdl"

DEFINE_BASECLASS( "raft_piece_base" )

function ENT.IsValidPlacement( piece, dir )
    if piece:GetClass() ~= "raft_foundation" then return false end
    return BaseClass.IsValidPlacement( piece, dir )
end
