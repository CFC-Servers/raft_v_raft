AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

SWEP.PrintName = "Raft Builder"
SWEP.HoldType = "melee"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crwobar.mdl"

local abs = math.abs
SWEP.Placements = {
    raft_foundation = {},
}

function SWEP:GetAimEntity()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid( ent ) then return nil end

    return ent
end

function SWEP:GetPlacementDirection()
    local ent = self:GetAimEntity()
    if not ent then return end
    local validDirections = self.Placements[ent:GetClass()]
    if not validDirections then return end
    
    local ply = self:GetOwner()
    
    local pos = ply:GetAimVector() + ent:GetPos()
    local dir = ent:WorldToLocal(pos)
    dir.z = 0
    
    dir.x = math.Round(dir.x)
    dir.y = math.Round(dir.y)
    if abs(dir.y) == abs(dir.x) then return end -- no diagonal placement

    return dir
end
