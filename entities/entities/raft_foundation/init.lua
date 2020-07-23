AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:PhysicsUpdate( phys )
    local mass = phys:GetMass()

    local zPos = self:GetPos().z
    local difference = RVR.waterSurfaceZ+10 - zPos
    
    if difference > 1000 then return end

    local force = Vector( -5, 10, difference ) - phys:GetVelocity() * 0.7
    phys:ApplyForceCenter( force * mass)

    RVR.Util.keepAnglesThink( phys )
end
