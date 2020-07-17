surface.CreateFont( "RVR_RadialMenu_Title", {
    font = "Bungee Regular",
    size = 30,
    weight = 500,
})

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
    if not self.selectedItem then return end
    local item = self.items[self.selectedItem]
    item.callback()
end

function radialMeta:Paint()
    local aimAng = 360 - getCursorAng()
    aimAng = ( aimAng - 90 ) % 360

    self:DrawSelected()

    local buttonCount = #self.items
    local buttonSize = math.ceil( 360 / buttonCount )

    for i=0, buttonCount - 1 do
        surface.SetDrawColor( self.color )

        if aimAng > i * buttonSize and aimAng < buttonSize + i * buttonSize then
            surface.SetDrawColor( self.selectedColor )
            self.selectedItem = i + 1
        end

        local mat = self.items[i+1].iconMaterial

        self:DrawButton( i * buttonSize, buttonSize, mat )
    end

    self:customPaint()
end

function radialMeta:GetHookIdentifier()
    return "RVR_RadialMenu_" .. tostring( self )
end

function radialMeta:Open()
    gui.EnableScreenClicker( true )

    timer.Simple(0, function()
        input.SetCursorPos( ScrW() / 2, ScrH() / 2)
    end)

    hook.Add( "HUDPaint", self:GetHookIdentifier(), function()
        self:Paint()
    end )
end

function radialMeta:Close()
    gui.EnableScreenClicker( false )
    hook.Remove( "HUDPaint", self:GetHookIdentifier() )
end

function radialMeta:DrawSelected()
    if not self.selectedItem then return end
    local item = self.items[self.selectedItem]
    local centerx, centery = ScrW() / 2, ScrH() / 2

    surface.SetDrawColor(self.infoCircleColor)
    draw.NoTexture()
    local points = {}
    for a=360, 0, -1 do
        table.insert(points, newPoint(centerx, centery, a, self.infoCircleRadius) )
    end
    surface.DrawPoly( points )

    draw.DrawText( item.name, "RVR_RadialMenu_Title", centerx, ScrH() * 0.4, self.titleColor, TEXT_ALIGN_CENTER)

    surface.SetMaterial( item.iconMaterial )
    local iconSize = 100
    surface.DrawTexturedRect( centerx - iconSize / 2, ScrH() * 0.47 - iconSize / 2, iconSize, iconSize )
end

function radialMeta:DrawSegment( start, size )
    if self.pointCache[start] then
        return surface.DrawPoly( self.pointCache[start] )
    end
    local centerx, centery = ScrW() / 2, ScrH() / 2
    local points = {}

    for a = size+start, start, -1 do
        table.insert( points, newPoint( centerx, centery, a, self.outerRadius ) )
    end

    table.insert( points, newPoint( centerx, centery, start, self.innerRadius ) )
    table.insert( points, newPoint( centerx, centery, start+size, self.innerRadius ) )
    self.pointCache[start] = points
    surface.DrawPoly( points )
end

function radialMeta:DrawButton( start, size, mat )
    draw.NoTexture()

    local centerx, centery = ScrW() / 2, ScrH() / 2
    local segmentAmount = ( size ) / self.segmentSize
    segmentAmount = math.floor( segmentAmount )
    local segmentSize = math.ceil( size / segmentAmount )

    for i=0, segmentAmount-1 do
        local segmentStart = start + segmentSize * i
        self:DrawSegment( segmentStart, segmentSize )
    end

    surface.SetMaterial( mat )

    local pos = newPoint( centerx, centery, start + size / 2, self.iconRadius )

    local iconSize = size * 1.2
    surface.DrawTexturedRect( pos.x - iconSize / 2, pos.y - iconSize / 2, iconSize, iconSize )
end

function RVR.newRadialMenu()
    local r = {
        items         = {},
        color         = Color( 188, 162, 105, 255 ),
        selectedColor = Color( 255, 162, 105, 255 ),
        infoCircleColor = Color( 149, 130, 90, 100 ),
        titleColor = Color( 30, 30, 30, 255 ),
        outerRadius   = 300,
        innerRadius   = 175,
        iconRadius    = 230,
        segmentSize   = 5,
        pointCache    = {},
        infoCircleRadius = 200,
        customPaint = function() end
    }

    setmetatable(r, radialMeta)
    return r
end
