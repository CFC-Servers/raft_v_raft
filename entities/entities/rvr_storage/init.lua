AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    -- Default model, expected to be changed by derived classes
    self:SetModel( "models/props_junk/wood_crate001a.mdl" )
    -- Make it move
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        physObj:Wake()
        physObj:EnableMotion( true )
    end

    -- Give entity an inventory
    self.RVR_Inventory = {
        Inventory = {},
        MaxSlots = 50,
        InventoryType = "Box",
        Name = "Medium Storage",
    }
end

function ENT:SetStorageName( name )
    self.RVR_Inventory.Name = name
end

function ENT:SetMaxSlots( slotCount )
    self.RVR_Inventory.MaxSlots = slotCount
end

-- TODO: Perhaps check distance, unsure if gmod already has something for this
function ENT:Use( activator, caller )
    RVR.Inventory.playerOpenInventory( caller, self )
end
