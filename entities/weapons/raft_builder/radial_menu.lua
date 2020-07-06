local OUTER_RADIUS = 300
local INNER_RADIUS = 200
local ICON_RADIUS = ( OUTER_RADIUS - INNER_RADIUS ) * 0.60

local function getCursorAng()
    local x, y = input.GetCursorPos()
    x, y = x - ScrW() / 2, y - ScrH() / 2
    return math.deg( math.atan2(y, x) ) + 180
end

local function newPoint( centerx, centery, angle, radius )
    local radians = math.rad( angle )
    return {
        x = centerx + math.sin( radians ) * radius,
        y = centery + math.sin( radians ) * radius,
    }
end

local function drawRadialButton( start, size, mat )
    draw.NoTexture()

    local centerx, centery = ScrW() / 2, ScrH() / 2
    
    local points = {}
    
    for a = size+start, start, -1 do
        table.insert( points, newPoint( centerx, centery, a, OUTER_RADIUS ) )
    end

    table.insert( points, newPoint( centerx, centery, start, INNER_RADIUS ) )
    table.insert( points, newPoint( centerx, centery, start+size, INNER_RADIUS) )

    surface.DrawPoly( points )
    
    surface.SetMaterial( mat )
    
    local pos = newPoint( centerx, centery, start + size / 2, ICON_RADIUS )
    
    local iconSize = size * 2
    surface.DrawTexturedRect( pos.x - iconSize / 2, pos.y - iconSize / 2, iconSize, iconSize )
end


local items = { 
    { iconMaterial = Material("rvr/icons/water.png") },
    { iconMaterial = Material("rvr/icons/food.png") },
    { iconMaterial = Material("rvr/icons/food.png") },
    { iconMaterial = Material("rvr/icons/food.png") },
    { iconMaterial = Material("rvr/icons/food.png") },
}

local function PaintRadialMenu()
    local aimAng = 360 - getCursorAng()
    aimAng = ( aimAng - 90 ) % 360 
    draw.NoTexture()
    
    local buttonCount = #items
    local buttonSize = math.ceil( 360 / buttonCount )
    
    for i=0, buttonCount-1 do 
        surface.SetDrawColor( 188, 162, 105, 255 )
        
        if aimAng > i * buttonSize  and aimAng < buttonSize + i * buttonSize  then
            surface.SetDrawColor( 255, 162, 105, 255 )
        end

        local mat = items[i+1].iconMaterial
        
        drawRadialButton( i * segmentSize, segmentSize, mat ) 
    end 
end
