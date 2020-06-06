include("shared.lua") 

function SWEP:Initialize()
    self.ghost = ClientsideModel("models/hunter/plates/plate8x32.mdl")
end

function SWEP:OnRemove()
    self.ghost:Remove()
end

function SWEP:Think()
    local ent = self:GetAimEntity()
    if not ent then return end
    
    local size = ent:OBBMaxs() - ent:OBBMins()
    
    local dir = self:GetPlacementDirection()
    if not dir then return end
    
    
    self.ghost:SetModel(ent:GetModel())
    self.ghost:SetColor(Color(0, 255, 0, 100)) 
 
    self.ghost:SetPos(ent:LocalToWorld(dir*size[1]))
    self.ghost:SetAngles(ent:GetAngles())
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
