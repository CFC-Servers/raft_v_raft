local outerCircleMat = Material( "rvr/icons/radial_circle.png" )

surface.CreateFont( "RVR_RadialMenu_Title", {
    font = "Bungee Regular",
    size = ScrH() * 0.055,
    weight = 500
} )

local function getCursorAngAndDist()
    local x, y = input.GetCursorPos()
    x, y = x - ScrW() / 2, y - ScrH() / 2
    return math.deg( math.atan2( y, x ) ) + 180, Vector( x, y, 0 ):Length()
end

local function newPoint( centerX, centerY, angle, radius )
    local radians = math.rad( angle )
    return {
        x = centerX + math.sin( radians ) * radius,
        y = centerY + math.cos( radians ) * radius
    }
end

local radialMeta = {}
radialMeta.__index = radialMeta
function radialMeta:AddItem( name, material, callback )
    local item = {
        name = name,
        iconMaterial = material,
        callback = callback
    }

    table.insert( self.items, item )
    return item
end

function radialMeta:RunSelected()
    if not self.selectedItem then return end
    local item = self.items[self.selectedItem]
    item.callback()
end

local function drawCircle( x, y, radius, color )
    surface.SetDrawColor( color )
    draw.NoTexture()
    local points = {}
    for a = 360, 0, -1 do
        table.insert( points, newPoint( x, y, a, radius ) )
    end
    surface.DrawPoly( points )
end

function radialMeta:Paint()
    local aimAng, aimDist = getCursorAngAndDist()
    aimAng = ( ( 360 - aimAng ) - 90 ) % 360

    local centerX, centerY = ScrW() / 2, ScrH() / 2

    if self.showCenterOutline then
        drawCircle( centerX, centerY, self.infoCircleRadius + 4, self.secondarySelectedColor )
    end

    drawCircle( centerX, centerY, self.infoCircleRadius, self.infoCircleColor )

    self:DrawSelected()

    local outerCircleRadius = self.outerRadius * 1.11
    surface.SetDrawColor( 0, 0, 0, 230 )
    surface.SetMaterial( outerCircleMat )
    surface.DrawTexturedRect( centerX - outerCircleRadius, centerY - outerCircleRadius,
        outerCircleRadius * 2, outerCircleRadius * 2 )

    local buttonCount = #self.items
    local buttonSize = 360 / buttonCount

    self.selectedItem = nil

    for i = 0, buttonCount - 1 do
        local color = self.color
        local matColor = Color( 255, 255, 255 )

        local startAng = math.ceil( i * buttonSize )
        local endAng = math.ceil( ( i + 1 ) * buttonSize )

        local inAngularRange = aimAng > startAng and aimAng < endAng
        local inSegment = inAngularRange and aimDist > self.infoCircleRadius

        if inSegment then
            color = self.selectedColor
            matColor = self.secondarySelectedColor
            self.selectedItem = i + 1

            self:DrawOuterCircleSegment( startAng, endAng - startAng )
        end

        local mat = self.items[i + 1].iconMaterial
        self:DrawButton( startAng, endAng - startAng, mat, color, matColor )
    end

    self:customPaint()
end

function radialMeta:GetHookIdentifier()
    return "RVR_RadialMenu_" .. tostring( self )
end

-- From gmod wiki
local function drawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )
    local c = math.cos( math.rad( rot ) )
    local s = math.sin( math.rad( rot ) )

    local newx = y0 * s - x0 * c
    local newy = y0 * c + x0 * s

    surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )
end

function radialMeta:DrawOuterCircleSegment( start, size )
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local radius = self.outerRadius * self.outerRingRadiusMultiplier

    local doubleRadiusSquared = 2 * radius * radius
    local normalWidth = math.ceil( math.sqrt( doubleRadiusSquared * ( 1 - math.cos( math.rad( 1 ) ) ) ) )
    local h = self.outerRadius * 0.075
    draw.NoTexture()
    surface.SetDrawColor( self.secondarySelectedColor )
    for a = start, size + start - 1 do
        local pos = newPoint( centerX, centerY, a, radius )

        local w = normalWidth
        if a < size + start - 1 then
            w = w + 2
        end
        drawTexturedRectRotatedPoint( math.floor( pos.x ), math.floor( pos.y ), w, h, a, -w * 0.5, -h * 0.5 )
    end
end

function radialMeta:Open()
    gui.EnableScreenClicker( true )

    timer.Simple( 0, function()
        input.SetCursorPos( ScrW() / 2, ScrH() / 2 )
    end )

    hook.Add( "HUDPaint", self:GetHookIdentifier(), function()
        self:Paint()
    end )

    self.isOpen = true
end

function radialMeta:Close()
    gui.EnableScreenClicker( false )
    hook.Remove( "HUDPaint", self:GetHookIdentifier() )

    self.isOpen = false
end

function radialMeta:DrawSelected()
    if not self.selectedItem then return end
    local item = self.items[self.selectedItem]

    local x, y = ScrW() * 0.5, ScrH() * 0.44

    draw.DrawText( item.name, "RVR_RadialMenu_Title", x, y, self.titleColor, TEXT_ALIGN_CENTER )
end

function radialMeta:SetShowCenterOutline( show )
    self.showCenterOutline = show
end

function radialMeta:DrawSegment( start, size, color )
    surface.SetDrawColor( color )
    if self.pointCache[start] then
        return surface.DrawPoly( self.pointCache[start] )
    end
    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local points = {}

    for a = size + start, start, -1 do
        table.insert( points, newPoint( centerX, centerY, a, self.outerRadius ) )
    end

    table.insert( points, newPoint( centerX, centerY, start, self.innerRadius ) )
    table.insert( points, newPoint( centerX, centerY, start + size, self.innerRadius ) )
    self.pointCache[start] = points
    surface.DrawPoly( points )
end

function radialMeta:DrawButton( start, size, mat, color, matColor )
    draw.NoTexture()

    local centerX, centerY = ScrW() / 2, ScrH() / 2
    local segmentAmount = size / self.segmentSize
    segmentAmount = math.floor( segmentAmount )

    local segmentSize = size / segmentAmount

    for i = 0, segmentAmount - 1 do
        local segmentStart = math.floor( start + segmentSize * i )
        local nextI = ( i + 1 ) % segmentAmount
        local nextSegmentStart = math.floor( start + segmentSize * nextI )

        local segmentSizeInt = nextSegmentStart - segmentStart
        if segmentSizeInt < 0 then
            segmentSizeInt = segmentSizeInt + size
        end

        self:DrawSegment( segmentStart, segmentSizeInt, color )
    end

    surface.SetDrawColor( matColor )
    surface.SetMaterial( mat )

    local pos = newPoint( centerX, centerY, start + size / 2, self.iconRadius )

    local iconSize = size * 1.7
    surface.DrawTexturedRect( pos.x - iconSize / 2, pos.y - iconSize / 2, iconSize, iconSize )
end

function RVR.newRadialMenu()
    local r = {
        items = {},
        color = Color( 0, 0, 0, 150 ),
        selectedColor = Color( 255, 255, 255, 50 ),
        secondarySelectedColor = Color( 156, 0, 0, 255 ),
        infoCircleColor = Color( 50, 50, 50, 255 ),
        titleColor = Color( 255, 255, 255, 255 ),
        outerRadius = ScrH() * 0.28,
        innerRadius = ScrH() * 0.14,
        infoCircleRadius = 110,
        iconRadius = 230,
        segmentSize = 5,
        outerRingRadiusMultiplier = 1.116,
        pointCache = {},
        customPaint = function() end
    }

    setmetatable( r, radialMeta )
    return r
end
