AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    -- Default model, expected to be changed by derived classes
    self:SetModel( self.Model )
    -- Make it move
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE )

    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        physObj:Wake()
        physObj:EnableMotion( true )
    end

    RVR.Crafting.makeCrafter( self, self.CrafterName, self.Tier, self.CrafterType )
end

function ENT:Use( activator, caller )
    RVR.Crafting.openMenu( caller, self )
end
