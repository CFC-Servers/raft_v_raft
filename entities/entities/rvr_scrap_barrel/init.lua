AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self.BaseClass.Initialize( self )

    -- TODO shared despawnable storage baseclass with death box
    -- Set up despawn timer
    local despawnTime = 300
    if despawnTime > 0 then
        self.timerIdentifier = "rvr_scrap_barrel_despawn_" .. self:EntIndex()
        local this = self

        timer.Create( this.timerIdentifier, despawnTime, 1, function()
            if IsValid( this ) then this:Remove() end
        end )
    end
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:SetBuoyancyRatio( 0.7 )
    end
end

function ENT:OnRemove()
    if self.timerIdentifier then
        timer.Remove( self.timerIdentifier )
    end
end

function ENT:SetItems( items )
    for i = 1, #items  do
        local item = items[i]
        if item and item.itemType then
            RVR.Inventory.setSlot( self, i, { 
                item = RVR.Items.getItemData( item.itemType ), 
                count = item.count 
            } )
        end
    end
 
    self.RVR_Inventory.PreventAdding = true   
end
