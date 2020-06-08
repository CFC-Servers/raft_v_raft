-- https:--wiki.facepunch.com/gmod/ENTITY:GravGunPickupAllowed
-- https:--wiki.facepunch.com/gmod/ENTITY:OnRemove
--  ENTITY:PhysicsCollide( table colData, PhysObj collider )
-- https:--wiki.facepunch.com/gmod/ENTITY:PhysicsSimulate
-- https:--wiki.facepunch.com/gmod/ENTITY:Touch
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/wood/wood_panel4x4.mdl") 
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
  
    self:StartMotionController() 
    self.shadowParams = {}
    self.shadowPos = self:GetPos()
    self.shadowPos.z = 1000
    self.shadowAngle =  Angle(0,0,0)
end

function ENT:PhysicsSimulate( phys, deltaTime ) 
    phys:Wake()
 
	self.shadowParams.secondstoarrive = 5 
	self.shadowParams.pos = self.shadowPos 
	self.shadowParams.angle = self.shadowAngle
	self.shadowParams.maxangular = 5000 
	self.shadowParams.maxangulardamp = 10000
	self.shadowParams.maxspeed = 1000000
	self.shadowParams.maxspeeddamp = 10000
	self.shadowParams.dampfactor = 0.8
	self.shadowParams.teleportdistance = 200
	self.shadowParams.deltatime = deltatime
 
	phys:ComputeShadowControl(self.shadowParams) 
end

function ENT:SetRaft()
    self.raft = {}
end

