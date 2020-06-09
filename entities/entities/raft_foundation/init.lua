AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/wood/wood_panel4x4.mdl") 
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
  
    self:StartMotionController() 
    
    local shadowPos = self:GetPos()
    shadowPos.z = 100
    shadowAngle =  Angle(0,0,0)
    
    self.shadowParams = {
        secondstoarrive = 1,
        pos = shadowPos,
        angle = Angle(0,0,0),
        maxangular = 5000,
        maxangulardamp = 10000,
        maxspeed = 1000000,
        maxspeeddamp = 10000,
        dampfactor = 0.8,
        teleportdistance = 200,
        deltatime = 0,
    }

    local phys = self:GetPhysicsObject()
    phys:Wake()
end

function ENT:PhysicsSimulate( phys, deltaTime ) 
    phys:Wake()
	
	self.shadowParams.pos = self.shadowPos 
	self.shadowParams.angle = self.shadowAngle
	self.shadowParams.deltatime = deltatime
 
	phys:ComputeShadowControl(self.shadowParams) 
end

function ENT:SetRaft()
    self.raft = {}
end

