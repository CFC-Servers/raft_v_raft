AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( false )
    end
end

function ENT:OnRemove()
    self._removing = true
    local neighbors = self.raft:GetNeighbors( self )
    local raft = self:GetRaft()

    for _, ent in pairs( neighbors ) do
        if not ent:ShouldExist() then
            ent:Remove()
        end
    end
end

-- should the raft piece still exist e.g. a platform must have a foundation bellow it
function ENT:ShouldExist()
    return true
end

function ENT:PhysicsSimulate( phys, deltaTime )
end
