AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( true )
    end
    
    phys:SetMass(self.DefaultMass)
end

function ENT:OnRemove()
   if self._removing then return end
   self._removing = true

    local raft = self:GetRaft()
    local neighbors = raft:GetNeighbors( self )

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


function ENT:PhysicsUpdate( phys )
    local mass = phys:GetMass()

    local zPos = self:GetPos().z
    local difference = RVR.waterSurfaceZ+10 - zPos
    
    if difference > 1000 then return end

    local force = Vector( 0, 0, difference ) - phys:GetVelocity() * 0.7
    phys:ApplyForceCenter( force * mass)

    RVR.Util.keepAnglesThink( phys )
end

