local inv = RVR.Inventory

function inv.openPlayerInventory( inventory )
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "shit inventory" )
    frame:SetDeleteOnClose( false )
    frame:SetSize( ScrW() * 0.6, ScrH() * 0.8 )
    frame:SetDraggable( false )
    frame:Center()
    frame:MakePopup()

    function frame:OnClose()
        inv.closeInventory()
    end

    return frame
end