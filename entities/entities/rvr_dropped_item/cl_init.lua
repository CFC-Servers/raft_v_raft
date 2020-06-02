include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos()
    local angles = self:GetAngles()

    surface.SetFont("ChatFont")
    local text = self:GetItemName()
    local amount = self:GetAmount()

    if amount > 1 then
        text = text .. " (" .. amount .. ")"
    end

    local tWidth = surface.GetTextSize(text)

    -- TODO: change this to line up with prop
    cam.Start3D2D(pos + angles:Up() * 0.82, angles, 0.1)
        draw.WordBox(2, -tWidth * 0.5, -10, text, "ChatFont", Color(140, 0, 0, 100), Color(255, 255, 255, 255))
    cam.End3D2D()

end

function ENT:Think()
end
