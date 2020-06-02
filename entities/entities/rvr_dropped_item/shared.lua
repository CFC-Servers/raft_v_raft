ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dropped item"
ENT.Author = ""
ENT.Spawnable = false
ENT.IsDroppedItem = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 1, "amount" )
    self:NetworkVar( "String", "", "itemType" )
end
