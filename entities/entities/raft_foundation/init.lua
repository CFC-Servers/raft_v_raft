AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/wood/wood_panel4x4.mdl") 
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )    
end

function ENT:PhysicsSimulate( phys, deltaTime ) 
end

