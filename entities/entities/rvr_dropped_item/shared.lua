ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Dropped item"
ENT.Author = ""
ENT.Spawnable = false
ENT.IsDroppedItem = true

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Amount" )
    self:NetworkVar( "String", 0, "ItemType" )
    self:NetworkVar( "String", 0, "ItemDisplayName" )

    if SERVER then
        self:SetAmount( 1 )
        self:SetItemType( "" )
        self:SetItemDisplayName( "" )
    end
end
