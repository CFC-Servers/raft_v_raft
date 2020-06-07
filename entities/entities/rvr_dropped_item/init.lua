AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function getSafeRemover( ent )
    return function()
        if IsValid( ent ) then ent:Remove() end
    end
end

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

    local despawnTime = GAMEMODE.Config.Inventory.ITEM_DESPAWN_TIME
    if despawnTime > 0 then
        timer.Create( "rvr_dropped_item_despawn_" .. self:EntIndex(), despawnTime, 1, getSafeRemover( self ) )
    end
end

function ENT:Setup( item, count )
    self:SetAmount( count )
    self:SetItemType( item.type )
    self:SetItemDisplayName( item.displayName )
    self:SetModel( item.model )

    self.item = item
end

function ENT:StartTouch( other )
    if other:GetClass() ~= "rvr_dropped_item" or self.USED or other.USED or self.MERGED or other.MERGED then return end
    if not RVR.Inventory.canItemsStack( self.item, other.item ) then return end

    other.MERGED = true

    other:Remove()

    self:SetAmount( self:GetAmount() + other:GetAmount() )

    -- Reset despawn time
    local despawnTime = GAMEMODE.Config.Inventory.ITEM_DESPAWN_TIME
    if despawnTime > 0 then
        timer.Adjust( "rvr_dropped_item_despawn_" .. self:EntIndex(), despawnTime, 1, getSafeRemover( self ) )
    end
end

function ENT:OnRemove()
    timer.Remove( "rvr_dropped_item_despawn_" .. self:EntIndex() )
end

function ENT:Use( activator, caller )
    if self.USED or self.MERGED then return end

    local success, amount = RVR.Inventory.attemptPickupItem( caller, self.item, self:GetAmount() )
    if success then
        self.USED = true
        self:Remove()
        return
    end

    if amount == 0 then return end

    self:SetAmount( self:GetAmount() - amount )
end
