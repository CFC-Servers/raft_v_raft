AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/rvr/raft/raft_base.mdl") 
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )    

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then 
        phys:EnableMotion(false)
    end
end

function ENT:PhysicsSimulate( phys, deltaTime ) 
end

