ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "CFC"
ENT.PrintName = ""
ENT.Model = ""
ENT.IsRaft = true

function ENT:SetRaft( raft )
    self.raft = raft
end

function ENT:GetRaft( raft )
    self.raft = raft
end
