local PANEL = {}

function PANEL:Init()
    self:SetImage( "materials/slot_background.png" )

    self.itemImage = vgui.Create( "DImage", self )
    self.itemImage:Dock( FILL )
    self.itemImage:DockMargin( 5, 5, 5, 5 )

    self.itemCount = vgui.Create( "DLabel", self )
    self.itemCount:SetText( "" )

    function self.itemCount:PerformLayout()
        self:SizeToContents()
        local pw, ph = self:GetParent():GetSize()

        local w, h = self:GetSize()

        self:SetPos( pw - w, ph - h )
    end
end

function PANEL:SetLocationData( ent, position )
    self.parentEnt = ent
    self.slotPosition = position
end

function PANEL:OnMousePressed( code )
    local handSlot = LocalPlayer().handSlot

    
end

function PANEL:SetItemData( item, count )
    self.item = item
    self.itemCount = count
    self.itemImage:SetImage( item.icon )

    if count > 1 then
        self.itemCount:SetText( tostring( count ) )
    else
        self.itemCount:SetText( "" )
    end
    self.itemCount:InvalidateLayout()
end

vgui.Register( "RVR_ItemSlot", PANEL, "DImage" )