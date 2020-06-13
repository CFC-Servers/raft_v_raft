ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Dropped item"
ENT.Author = ""

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Amount" )
    self:NetworkVar( "String", 0, "ItemType" )
    self:NetworkVar( "String", 1, "ItemDisplayName" )

    if SERVER then
        self:SetAmount( 1 )
        self:SetItemType( "" )
        self:SetItemDisplayName( "" )
    end
end
