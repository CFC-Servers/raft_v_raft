ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "CFC"
ENT.PrintName = "Raft Foundation"
ENT.IsRaft = true

function ENT:SetRaft( raft )
    self.raft = raft
end

function ENT:GetRaft( raft )
    self.raft = raft
end
