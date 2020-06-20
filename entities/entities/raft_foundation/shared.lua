ENT.Base = "raft_base"
ENT.PrintName = "Raft Foundation"
ENT.Model = "models/rvr/raft/raft_base.mdl"

DEFINE_BASECLASS("raft_base")

function ENT.IsValidPlacement(piece, dir)
    if piece:GetClass() ~= "raft_foundation" then return false end
    return BaseClass.IsValidPlacement(piece, dir)
end
