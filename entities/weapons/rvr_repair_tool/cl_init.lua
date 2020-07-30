include( "shared.lua" )

surface.CreateFont( "RVR_RepairToolhealth", {
    font = "Bungee Regular",
    size = ScrH() * 0.09,
    weight = 700
} )

function SWEP:PrimaryAttack()
end

function SWEP:HudDraw()
    if self:GetOwner():GetActiveWeapon() ~= self then return end

    local traceData = self:GetOwner():GetEyeTrace()
    local aimEnt = traceData.Entity

    if not aimEnt then return end
    if not aimEnt.IsRaft and not aimEnt.IsWall then return end

    local centX, centY = ScrW() * 0.5, ScrH() * 0.47

    local hp = aimEnt:Health()
    local maxHp = aimEnt:GetMaxHealth()

    local prog = hp / maxHp

    local w, h = ScrW() * 0.1, ScrH() * 0.03
    local padding = 2

    local x, y = centX - w * 0.5, centY - h * 0.5

    local col = HSVToColor( prog * 120, 1, 0.5 )
    surface.SetDrawColor( col )
    surface.DrawRect( x, y, w, h )

    col = HSVToColor( prog * 120, 1, 1 )
    surface.SetDrawColor( col )
    surface.DrawRect( x + padding, y + padding, ( w - padding * 2 ) * prog, h - padding * 2 )
end

function SWEP:AddHalo()
    if self:GetOwner():GetActiveWeapon() ~= self then return end

    local traceData = self:GetOwner():GetEyeTrace()
    local aimEnt = traceData.Entity

    if not aimEnt then return end
    if not aimEnt.IsRaft and not aimEnt.IsWall then return end

    local hp = aimEnt:Health()
    local maxHp = aimEnt:GetMaxHealth()

    local prog = hp / maxHp
    col = HSVToColor( prog * 120, 1, 1 )

    halo.Add( { aimEnt }, col, 5, 5, 2 )
end

function SWEP:GetHookIdentifier()
    return "RVR_RepairTool_HudDraw" .. tostring( self )
end

function SWEP:Initialize()
    self.pitch = 0

    local this = self
    hook.Add( "HUDPaint", this:GetHookIdentifier(), function()
        this:HudDraw()
    end )

    hook.Add( "PreDrawHalos", this:GetHookIdentifier(), function()
        this:AddHalo()
    end )
end

function SWEP:OnRemove()
    hook.Remove( "HUDPaint", self:GetHookIdentifier() )
    hook.Remove( "PreDrawHalos", self:GetHookIdentifier() )
end

function SWEP:Think()
    local mouseDown = input.IsMouseDown( input.GetKeyCode( input.LookupBinding( "+attack" ) ) )

    if mouseDown and self.animSpeed < 1 then
        self.animSpeed = math.min( self.animSpeed + FrameTime(), 1 )
    elseif not mouseDown and self.animSpeed > 0 then
        self.animSpeed = math.max( self.animSpeed - FrameTime(), 0 )
    end
end

function SWEP:GetViewModelPosition( eyePos, eyeAng )
    eyePos, eyeAng = self.BaseClass.GetViewModelPosition( self, eyePos, eyeAng )

    self.animSpeed = self.animSpeed or 0

    self.pitch = self.pitch + self.animSpeed * FrameTime() * 100

    eyePos = Vector( eyePos.x, eyePos.y, eyePos.z )
    eyeAng = Angle( eyeAng.x, eyeAng.y, eyeAng.z )

    local offset = Vector( 12, -6, -5 )
    offset:Rotate( eyeAng )
    eyePos = eyePos + offset

    eyeAng = eyeAng + Angle( self.pitch, 0, 0 )

    return eyePos, eyeAng
end
