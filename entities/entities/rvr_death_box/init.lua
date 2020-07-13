AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

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
    -- TODO: Make this do something
    self.RVR_Inventory.PreventAdding = true

    RVR.Inventory.clearInventory( ply )
end