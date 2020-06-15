AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

-- Generates function to remove ent if it exists
local function getSafeRemover( ent )
    return function()
        if IsValid( ent ) then ent:Remove() end
    end
end

function ENT:Initialize()
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

    -- Set up despawn timer
    local despawnTime = GAMEMODE.Config.Inventory.ITEM_DESPAWN_TIME
    if despawnTime > 0 then
        timer.Create( "rvr_dropped_item_despawn_" .. self:EntIndex(), despawnTime, 1, getSafeRemover( self ) )
    end
end

function ENT:RestartDespawnTimer()
    local despawnTime = GAMEMODE.Config.Inventory.ITEM_DESPAWN_TIME
    if despawnTime > 0 then
        timer.Adjust( "rvr_dropped_item_despawn_" .. self:EntIndex(), despawnTime, 1, getSafeRemover( self ) )
    end
end

-- Set dropped item information
function ENT:Setup( item, count )
    self:SetAmount( count )
    self:SetItemType( item.type )
    self:SetItemDisplayName( item.displayName )
    self:SetModel( item.model )

    self.item = item
end

-- On contact, merge if same item
-- Also, restart despawn timer
function ENT:StartTouch( other )
    if other:GetClass() ~= "rvr_dropped_item" or self.DELETING or other.DELETING then return end
    if not RVR.Inventory.canItemsStack( self.item, other.item ) then return end

    other.DELETING = true

    other:Remove()

    self:SetAmount( self:GetAmount() + other:GetAmount() )

    self:RestartDespawnTimer()
end

function ENT:OnRemove()
    timer.Remove( "rvr_dropped_item_despawn_" .. self:EntIndex() )
end

function ENT:Use( activator, caller )
    if self.DELETING then return end

    -- Try pick up
    local success, amount = RVR.Inventory.attemptPickupItem( caller, self.item, self:GetAmount() )
    if success then
        self.DELETING = true
        self:Remove()
        return
    end

    -- If couldn't pick up all, reduce self amount to correct value and restart despawn timer
    if amount == 0 then return end

    self:SetAmount( self:GetAmount() - amount )

    self:RestartDespawnTimer()
end
