AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/wood/wood_panel4x4.mdl")
    self:SetSolid(SOLID_VPHYSICS)
    
    self:PhysWake()
end


function ENT:SetRaft()
    self.raft = {}
end

