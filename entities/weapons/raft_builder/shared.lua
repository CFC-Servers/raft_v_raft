AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

SWEP.PrintName = "Raft Builder"
SWEP.HoldType = "melee"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crwobar.mdl"

local abs = math.abs

function SWEP:GetAimEntity()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid( ent ) then return nil end

    return ent
end

function SWEP:GetPlacementDirection()
end
