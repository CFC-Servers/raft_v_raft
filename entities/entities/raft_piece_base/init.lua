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

    local force = Vector( 0, 0, difference ) - phys:GetVelocity()
    phys:ApplyForceCenter( force*mass)


    local entAng = phys:GetAngles()
    local forward = Vector( 1, 0, 0 ):Angle()

    local pitch = math.rad( math.AngleDifference( entAng.pitch, forward.pitch ) )
    local yaw = 0
    local roll = math.rad( math.AngleDifference( entAng.roll, forward.roll ) )

    local damp = 0.75
    local strength = 500
    local divAng = Vector( pitch, yaw, 0 )
    divAng:Rotate( Angle( 0, -entAng.roll, 0 ) )

    phys:AddAngleVelocity( ( -Vector( roll, divAng.x, divAng.y ) * strength ) - ( phys:GetAngleVelocity() * damp ) )
end

