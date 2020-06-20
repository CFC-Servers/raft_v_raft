ENT.Base = "raft_base"
ENT.PrintName = "Raft Platform"
ENT.Model = "models/rvr/raft/raft_platform.mdl"

function ENT.IsValidPlacement(piece, dir)
    if piece:GetClass() ~= "raft_foundation" or piece:GetClass() ~= "raft_platform" then
        return false 
    end

    return dir == Vector(0, 0, 1)
end

