AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
    self:SetModel( "models/props_junk/wood_crate001a.mdl" )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        physObj:Wake()
        physObj:EnableMotion( true )
    end

    self.RVR_Inventory = {
        Inventory = {
        },
        MaxSlots = 30,
        InventoryType = "Box"
    }
end

function ENT:Use( activator, caller )
    RVR.Inventory.playerOpenInventory( caller, self )
end
