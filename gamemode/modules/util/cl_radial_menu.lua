local function getCursorAng()
    local x, y = input.GetCursorPos()
    x, y = x - ScrW() / 2, y - ScrH() / 2
    return math.deg( math.atan2(y, x) ) + 180
end

local function newPoint( centerx, centery, angle, radius )
    local radians = math.rad( angle )
    return {
        x = centerx + math.sin( radians ) * radius,
        y = centery + math.cos( radians ) * radius,
    }
end


local radialMeta = {}
radialMeta.__index = radialMeta
function radialMeta:AddItem( name, material, callback )
    local item = {
        name = name,
        iconMaterial = material,
        callback     = callback,
    }

    table.insert( self.items, item )
    return item
end

function radialMeta:RunSelected()
    local item  = self.items[self.selectedItem]
    item.callback()
end

function radialMeta:Paint()
    local aimAng = 360 - getCursorAng()
    aimAng = ( aimAng - 90 ) % 360
    draw.NoTexture()

    local buttonCount = #self.items
    local buttonSize = math.ceil( 360 / buttonCount )

    for i=0, buttonCount-1 do
        surface.SetDrawColor( self.color )

        if aimAng > i * buttonSize  and aimAng < buttonSize + i * buttonSize  then
            surface.SetDrawColor( self.selectedColor )
            self.selectedItem = i+1
        end

        local mat = self.items[i+1].iconMaterial

        self:DrawButton( i * buttonSize, buttonSize, mat )
    end
end

function radialMeta:Open()
    hook.Add( "HUDPaint", "RVR_RadialMenu_"..tostring(self), function()
        self:Paint()
    end )
end

function radialMeta:Close()
    hook.Remove( "HUDPaint", "RVR_RadialMenu_"..tostring(self) )
end

function radialMeta:DrawButton( start, size, mat )
    draw.NoTexture()

    local centerx, centery = ScrW() / 2, ScrH() / 2

    local points = {}

    for a = size+start, start, -1 do
        table.insert( points, newPoint( centerx, centery, a, self.outerRadius ) )
    end

    table.insert( points, newPoint( centerx, centery, start, self.innerRadius ) )
    table.insert( points, newPoint( centerx, centery, start+size, self.innerRadius ) )

    surface.DrawPoly( points )

    surface.SetMaterial( mat )

    local pos = newPoint( centerx, centery, start + size / 2, self.iconRadius )

    local iconSize = size * 2
    surface.DrawTexturedRect( pos.x - iconSize / 2, pos.y - iconSize / 2, iconSize, iconSize )
end

function RVR.newRadialMenu()
    local r = {
        items         = {},
        color         = Color( 188, 162, 105, 255 ),
        selectedColor = Color( 255, 162, 105, 255 ),
        outerRadius   = 300,
        innerRadius   = 200,
        iconRadius    = 250,

    }

    setmetatable(r, radialMeta)
    return r
end
