include( "shared.lua" )

function ENT:Draw()
    self:DrawModel()

    -- Item label with count
    local minDist = 120
    local fadeDist = 40
    local labelScale = 0.5

    -- Calculate opacity based on distance, keep at full opacity for 'minDist', then fade over 'fadeDist'
    local offset = LocalPlayer():GetPos() - self:GetPos()
    local ang = offset:Angle().yaw
    local dist = offset:Length()

    local progress = math.Clamp( ( dist - minDist ) / fadeDist, 0, 1 )
    local opacity = ( 1 - progress ) * 255

    if opacity == 0 then return end

    local pos = self:GetPos()
    local size = self:OBBMaxs() - self:OBBMins()

    local maxSide = math.max( size.x, size.y, size.z )

    local text = self:GetItemDisplayName()
    local amount = self:GetAmount()

    -- Add count
    if amount > 1 then
        text = text .. " (" .. amount .. ")"
    end

    local textY = maxSide / 2 + 4
    -- Add bobbing animation
    textY = textY + math.sin( CurTime() * 2 ) * 2

    -- TODO: Perhaps decide on different font
    cam.Start3D2D( pos + Vector( 0, 0, textY ), Angle( 0, ang + 90, 90 ), labelScale )
        draw.Text( {
            text = text,
            pos = { 0, -10 },
            color = Color( 255, 255, 255, opacity ),
            font = "ChatFont",
            xalign = TEXT_ALIGN_CENTER,
        } )
    cam.End3D2D()
end
