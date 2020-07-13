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
    local itemData = RVR.Items.getItemData( item.type )

    self:SetAmount( count )
    self:SetItemType( itemData.type )
    self:SetItemDisplayName( itemData.displayName )
    if itemData.model then
        self:SetModel( itemData.model )
    elseif item.swep then
        local wep = weapons.Get( itemData.swep )
        if wep.Model then
            self:SetModel( wep.Model )
        end
    end

    self.item = item
end

function ENT:Remove()
    self.deleting = true
    self.BaseClass.Remove( self )
end

-- On contact, merge if same item
-- Also, restart despawn timer
function ENT:StartTouch( collider )
    if collider:GetClass() ~= "rvr_dropped_item" or self.deleting or collider.deleting then return end
    if not RVR.Inventory.canItemsStack( self.item, collider.item ) then return end

    collider:Remove()

    self:SetAmount( self:GetAmount() + collider:GetAmount() )

    self:RestartDespawnTimer()
end

function ENT:OnRemove()
    timer.Remove( "rvr_dropped_item_despawn_" .. self:EntIndex() )
end

function ENT:Use( activator, caller )
    if self.deleting then return end

    -- Try pick up
    local success, amount = RVR.Inventory.attemptPickupItem( caller, self.item, self:GetAmount() )
    if success then
        self:Remove()
        return
    end

    -- If couldn't pick up all, reduce self amount to correct value and restart despawn timer
    if amount == 0 then return end

    self:SetAmount( self:GetAmount() - amount )

    self:RestartDespawnTimer()
end
