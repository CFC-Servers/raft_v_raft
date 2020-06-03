local PANEL = {}

function PANEL:Init()
    self:SetImage( "materials/icons/slot_background.png" )

    self.itemImage = vgui.Create( "DImage", self )
    self.itemImage:Dock( FILL )
    self.itemImage:DockMargin( 7, 7, 7, 7 )

    self.itemCountLabel = vgui.Create( "DLabel", self )
    self.itemCountLabel:SetText( "" )
    self.itemCountLabel:SetFont( "DermaLarge" )

    function self.itemCountLabel:PerformLayout()
        self:SizeToContents()
        local pw, ph = self:GetParent():GetSize()

        local w, h = self:GetSize()

        self:SetPos( pw - w - 7, ph - h )
    end
end

function PANEL:SetLocationData( ent, position )
    self.parentEnt = ent
    self.slotPosition = position
end

function PANEL:OnMousePressed( code )
    
end

function PANEL:SetItemData( item, count )
    self.item = item
    self.itemCount = count
    self.itemImage:SetImage( item.icon )

    if count > 1 then
        self.itemCountLabel:SetText( tostring( count ) )
    else
        self.itemCountLabel:SetText( "" )
    end
    self.itemCountLabel:SizeToContents()
end

vgui.Register( "RVR_ItemSlot", PANEL, "DImage" )