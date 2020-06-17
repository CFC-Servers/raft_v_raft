RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory

local PANEL = {}

-- List of all visible slots for updating
inv.ItemSlots = inv.ItemSlots or {}

function PANEL:Init()
    table.insert( inv.ItemSlots, self )
    self:SetImage( "materials/rvr/backgrounds/slot_background.png" )
    self:SetMouseInputEnabled( true )

    self.itemImage = vgui.Create( "DImage", self )
    self.itemImage:Dock( FILL )
    self.itemImage:DockMargin( 14, 14, 14, 14 )

    self.itemCountLabel = vgui.Create( "DLabel", self )
    self.itemCountLabel:SetText( "" )
    self.itemCountLabel:SetTextColor( Color( 200, 200, 200 ) )
    self.itemCountLabel:SetFont( "DermaLarge" )

    function self.itemCountLabel:PerformLayout()
        self:SizeToContents()
        local pw, ph = self:GetParent():GetSize()

        local w, h = self:GetSize()

        self:SetPos( pw - w - 13, ph - h - 5 )
    end

    self.toolTipText = vgui.Create( "DLabel" )
    self.toolTipText:SetText( "" )
    self.toolTipText:SetTextColor( Color( 0, 0, 0 ) )
    self.toolTipText:Hide()
end

function PANEL:SetLocationData( ent, position )
    self.parentEnt = ent
    self.slotPosition = position
end

function PANEL:GetLocationData()
    return self.parentEnt, self.slotPosition
end

function PANEL:OnMousePressed( code )
    local cursorItem, cursorItemCount = inv.getCursorItemData()

    if cursorItem then
        -- putting item into slot
        local count = cursorItemCount
        if code == MOUSE_RIGHT then
            count = 1
        end
        net.Start( "RVR_Inventory_CursorPut" )
        net.WriteEntity( self.parentEnt )
        net.WriteInt( self.slotPosition, 8 )
        net.WriteUInt( count, 8 )
        net.SendToServer()
    else
        if not self.item then return end
        -- taking item from slot

        local count = self.itemCount
        if code == MOUSE_RIGHT then
            count = math.ceil( count / 2 )
        end
        net.Start( "RVR_Inventory_CursorHold" )
        net.WriteEntity( self.parentEnt )
        net.WriteInt( self.slotPosition, 8 )
        net.WriteUInt( count, 8 )
        net.SendToServer()
    end
end

function PANEL:OnRemove()
    table.RemoveByValue( inv.ItemSlots, self )
end

function PANEL:SetItemData( item, count )
    self.item = item
    self.itemCount = count
    self.itemImage:SetImage( item.icon )
    self.itemImage:SetImageColor( Color( 255, 255, 255 ) )

    if count > 1 then
        self.itemCountLabel:SetText( tostring( count ) )
    else
        self.itemCountLabel:SetText( "" )
    end
    self.itemCountLabel:SizeToContents()

    self.toolTipText:Show()
    self:SetTooltipPanel( self.toolTipText )
    self.toolTipText:SetText( item.displayName )
    self.toolTipText:SizeToContents()
end

function PANEL:GetItemData()
    return self.item, self.itemCount
end

function PANEL:ClearItemData()
    self.item = nil
    self.itemCount = nil
    self.itemImage:SetImageColor( Color( 255, 255, 255, 0 ) )
    self.itemCountLabel:SetText( "" )

    self.toolTipText:Hide()
    self:SetTooltipPanel( false )
end

vgui.Register( "RVR_ItemSlot", PANEL, "DImage" )
