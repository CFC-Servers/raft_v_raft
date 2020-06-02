include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    local minDist = 120
    local fadeDist = 40
    local labelScale = 0.5

    local offset = LocalPlayer():GetPos() - self:GetPos()
    local ang = offset:Angle().yaw
    local dist = offset:Length()

    local opacity = ( 1 - math.Clamp( ( dist - minDist ) / fadeDist, 0, 1 ) ) * 255

    if opacity == 0 then return end

    local pos = self:GetPos()
    local size = self:OBBMaxs() - self:OBBMins()

    local maxSide = math.max( size.x, size.y, size.z )

    local text = self:GetItemType()
    local amount = self:GetAmount()

    if amount > 1 then
        text = text .. " (" .. amount .. ")"
    end

    cam.Start3D2D( pos + Vector( 0, 0, maxSide / 2 + 4 + math.sin( CurTime() * 2 ) * 2 ), Angle( 0, ang + 90, 90 ), labelScale )
        draw.Text( {
            text = text,
            pos = { 0, -10 },
            color = Color( 255, 255, 255, opacity ),
            font = "ChatFont",
            xalign = TEXT_ALIGN_CENTER,
        } )
    cam.End3D2D()

end

function ENT:Think()
end
