AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
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
end

function ENT:Setup( item, count )
    self:SetAmount( count )
    self:SetItemType( item.type )
    self:SetModel( item.model )

    self.item = item
end

function ENT:Use( activator, caller )
    if self.USED then return end

    local success, amount = RVR.Inventory.attemptPickupItem( ply, self.item, self:GetAmount() )
    if success then
        self.USED = true
        self:Remove()
        return
    end

    if amount == 0 then return end

    self:SetAmount( self:GetAmount() - amount )
end
