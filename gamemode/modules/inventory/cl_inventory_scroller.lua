local PANEL = {}

local backgroundMat = Material( "rvr/backgrounds/inventory_scroller_background.png" )

-- Makes the scrollbar look pretty
local function formatScrollbar( bar )
    bar:SetHideButtons( true )

    function bar:Paint( w, h )
        local offsetX = math.Round( w * 0.25 )
        local offsetY = 10
        draw.RoundedBox( 4, offsetX, offsetY, w - offsetX * 2, h - offsetY * 2, Color( 89, 55, 30 ) )
    end

    function bar.btnGrip:Paint( w, h )
        draw.RoundedBox( 10, 0, 0, w, h, Color( 188, 162, 105 ) )
    end
end

-- Creates the slots, called last (by setinventory)
function PANEL:SetupContent()
    self.scroller = vgui.Create( "DScrollPanel", self )
    self.scroller:Dock( FILL )
    self.scroller:DockMargin( 0, 2, 0, 3 )

    local scrollWidth = self:GetWide()
    formatScrollbar( self.scroller:GetVBar() )

    local slotOffset = self.startSlot - 1
    local slotCount = self.endSlot - slotOffset

    local slotsPerRow = self.slotsPerRow
    local rows = math.ceil( slotCount / slotsPerRow )
    local slotSize = ( scrollWidth * 0.94 ) / slotsPerRow
    self.slotSize = slotSize
    local spacing = slotSize * 0.2

    -- Panel placed within the scroller canvas to force the height to be what we want
    local canvasPanel = vgui.Create( "DPanel", self.scroller )
    canvasPanel:SetSize( slotSize * slotsPerRow, slotSize * rows )
    canvasPanel.Paint = nil

    -- Create and position slots
    for y = 0, rows - 1 do
        for x = 0, slotsPerRow - 1 do
            local index = y * slotsPerRow + x + 1
            if index > slotCount then break end

            index = index + slotOffset

            local slot = vgui.Create( "RVR_ItemSlot", canvasPanel )
            slot:SetSize( slotSize - spacing, slotSize - spacing )
            slot:SetPos( ( x * slotSize ) + spacing * 0.5, ( y * slotSize ) + spacing * 0.5 )
            if self.slotImage then
                slot:SetImage( self.slotImage )
            end

            slot:SetLocationData( self.ent, index )
            local itemInfo = self.inventory.Inventory[index]
            if itemInfo then
                slot:SetItemData( itemInfo.item, itemInfo.count )
            end
        end
    end
end

function PANEL:SetSlotsPerRow( slotsPerRow )
    self.slotsPerRow = slotsPerRow
end

function PANEL:GetSlotSize()
    return self.slotSize
end

function PANEL:SetSlotImage( img )
    self.slotImage = img
end

-- Set inventory with optional startSlot and endSlot, should be called last
function PANEL:SetInventory( inventory, startSlot, endSlot )
    self.startSlot = startSlot or 1
    self.endSlot = endSlot or inventory.MaxSlots
    self.inventory = inventory
    self.ent = inventory.Ent

    self:SetupContent()
end

function PANEL:SetBackgroundImage( img )
    self.backgroundMat = Material( string.sub( img, 11 ) ) -- To remove materials/, keep consistent with setSlotImage
end

function PANEL:Paint( w, h )
    surface.SetMaterial( self.backgroundMat or backgroundMat )
    surface.SetDrawColor( Color( 255, 255, 255 ) )
    surface.DrawTexturedRect( 0, 0, 0.94 * w, h )
end

vgui.Register( "RVR_InventoryScroller", PANEL )
