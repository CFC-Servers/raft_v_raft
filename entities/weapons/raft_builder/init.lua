include("shared.lua")

function SWEP:PrimaryAttack()
    local ent = self:GetAimEntity()
    local dir = self:GetPlacementDirection()
    if not (dir and ent) then return end
    
    local size = ent:OBBMaxs() - ent:OBBMins()
    
    local newEnt = ents.Create(ent:GetClass())
    newEnt:Spawn()
    newEnt:SetAngles(ent:GetAngles())
    newEnt:SetPos(ent:LocalToWorld(dir*size[1]))
    newEnt:SetParent( ent )
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

