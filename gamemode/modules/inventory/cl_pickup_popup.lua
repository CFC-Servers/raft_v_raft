RVR.Inventory = RVR.Inventory or {}
local inv = RVR.Inventory
inv.pickupPopups = {}

local popupOffset = 0

local popupHeight = math.Round( ScrH() * 0.07 )
local popupWidth = math.Round( popupHeight * ( 813 / 147 ) * 1.15 )
local popupSpacing = 3

local popupStart = ScrH() * 1
local popupWindowHeight = ScrH() * 0.5
local popupMaterial = Material( "rvr/backgrounds/item_pickup_popup_background.png" )
local popupItemMaterial = Material( "rvr/backgrounds/craftingmenu_ingredient.png" )

local popupDuration = 4
local brown = Color( 91, 56, 34 )

net.Receive( "RVR_Inventory_OnPickup", function()
    local itemData = net.ReadTable()
    local count = net.ReadUInt( 16 )

    table.insert( inv.pickupPopups, 1, { itemData = itemData, count = count, startTime = CurTime(), iconMat = Material( itemData.icon ) } )
    popupOffset = popupOffset - popupHeight - popupSpacing
end )

local prevTime = 0

function inv.drawPickupPopup( popup, x, y, w, h, alpha )
    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( popupMaterial )
    surface.DrawTexturedRect( x, y, w, h )

    local textW = h * 1.1
    surface.SetFont( "RVR_CraftingSubHeader" )
    surface.SetTextColor( brown.r, brown.g, brown.b, alpha )
    local text = "+" .. popup.count
    local tw, th = surface.GetTextSize( text )
    surface.SetTextPos( x + ( textW - tw ) * 0.5, y + ( h - th ) * 0.5 )
    surface.DrawText( text )

    local iconX, iconY, iconSize = x + textW, y + 2, h - 4
    surface.SetDrawColor( 255, 255, 255, alpha )
    surface.SetMaterial( popupItemMaterial )
    surface.DrawTexturedRect( iconX, iconY, iconSize, iconSize )

    local padding = 5
    surface.SetMaterial( popup.iconMat )
    surface.DrawTexturedRect( iconX + padding, iconY + padding, iconSize - padding * 2, iconSize - padding * 2 )

    local nameText = popup.itemData.displayName
    local _, nameTh = surface.GetTextSize( nameText )
    local nameX = x + textW + iconSize + 10
    surface.SetTextPos( nameX, y + ( h - nameTh ) * 0.5 )
    surface.DrawText( nameText )

    surface.SetDrawColor( brown.r, brown.g, brown.b, alpha )
    surface.DrawRect( nameX, y + h * 0.72, ( x + w ) - nameX - 10, 2 )
end

hook.Add( "HUDPaint", "RVR_Inventory_OnPickup", function()
    local x = ScrW() - popupWidth

    local cTime = CurTime()
    if prevTime == 0 then prevTime = cTime end

    local dTime = cTime - prevTime
    prevTime = cTime

    if popupOffset < 0 then
        popupOffset = math.min( popupOffset + dTime * popupHeight * 10, 0 )
    end

    render.SetScissorRect( x, popupStart - popupWindowHeight, ScrW(), popupStart, true )

        for k, popup in ipairs( inv.pickupPopups ) do
            local timePassed = cTime - popup.startTime
            local timeRemaining = popupDuration - timePassed
            if timeRemaining <= 0 then
                table.remove( inv.pickupPopups, k )
            else
                local fadeProg = 2 * math.Clamp( timeRemaining, 0, 0.5 )
                local y = popupStart - k * ( popupHeight + popupSpacing )

                if k ~= 1 then
                    y = y - popupOffset
                end

                local xOffsetProg = 1 - ( 10 * math.Clamp( timePassed, 0, 0.1 ) )
                local popupX = x + xOffsetProg * popupWidth

                inv.drawPickupPopup( popup, popupX, y, popupWidth, popupHeight, fadeProg * 255 )
            end
        end

    render.SetScissorRect( 0, 0, 0, 0, false )
end )