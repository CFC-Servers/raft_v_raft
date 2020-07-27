AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "raft_piece_base" )

function ENT:OnRemove()
    BaseClass.OnRemove( self )

    local raft = self:GetRaft()
    if not raft then return end

    raft:RemovePiece( self )
end

function ENT:SetRemoveTime( t )
    self.removeTime = CurTime() + t
end

function ENT:Think()
    BaseClass.Think( self )
    if self.removeTime and CurTime() > self.removeTime then
        self.removeTime = nil
        self:Remove()
    end
end
