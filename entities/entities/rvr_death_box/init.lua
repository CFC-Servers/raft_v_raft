AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self.BaseClass.Initialize( self )

    -- Set up despawn timer
    local despawnTime = GAMEMODE.Config.PlayerDeath.DEATH_BOX_DESPAWN_TIME
    if despawnTime > 0 then
        self.timerIdentifier = "rvr_death_box_despawn_" .. self:EntIndex()
        local this = self

        timer.Create( self.timerIdentifier, despawnTime, 1, function()
            if IsValid( this ) then this:Remove() end
        end )
    end
end

function ENT:OnRemove()
    if self.timerIdentifier then
        timer.Remove( self.timerIdentifier )
    end
end

function ENT:TakeFromPlayer( ply )
    if not ply.RVR_Inventory then return end

    self.RVR_Inventory.MaxSlots = 100

    local cursorData = RVR.Inventory.getSlot( ply, -1 )
    if cursorData then
        RVR.Inventory.attemptPickupItem( self, cursorData.item, cursorData.count )
    end

    for k = 1, ply.RVR_Inventory.MaxSlots + 3 do
        local slotData = RVR.Inventory.getSlot( ply, k )
        if slotData then
            RVR.Inventory.attemptPickupItem( self, slotData.item, slotData.count )
        end
    end

    self.RVR_Inventory.MaxSlots = #self.RVR_Inventory.Inventory
    self.RVR_Inventory.PreventAdding = true

    RVR.Inventory.clearInventory( ply )
end
