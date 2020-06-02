AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

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
