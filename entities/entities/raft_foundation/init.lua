AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "raft_piece_base" )

function ENT:PaddleMovementDecay()
    local raft = self:GetRaft()
    if not raft then return end

    local movement = raft:GetPaddleMovement()
    raft:SetPaddleMovement( movement * GAMEMODE.Config.Rafts.FOUNDATION_DRAG_MULTIPLIER  )
end

function ENT:PhysicsUpdate( phys )
    local mass = phys:GetMass()

    local zPos = self:GetPos().z
    local difference = RVR.waterSurfaceZ + 10 - zPos

    if difference > 1000 then return end

    local force = Vector( 0, 0, difference ) - phys:GetVelocity() * 0.9 + self:GetMovementVector()
    phys:ApplyForceCenter( force * mass)

    RVR.Util.keepAnglesThink( phys )
end

function ENT:GetMovementVector()
    local raft = self:GetRaft()
    if not raft then return Vector( 0, 0, 0 ) end
    return raft:GetMovement() + raft:GetPaddleMovement()
end

function ENT:SetRemoveTime( t )
    self.removeTime = CurTime() + t
end

function ENT:Think()
    self:PaddleMovementDecay()

    BaseClass.Think( self )
    if self.removeTime and CurTime() > self.removeTime then
        self.removeTime = nil
        self:Remove()
    end
end
