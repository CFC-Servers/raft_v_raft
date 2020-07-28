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

    if mouseDown and self.animProg < 1 then
        self.animProg = math.min( self.animProg + FrameTime() * 5, 1 )
    elseif not mouseDown and self.animProg > 0 then
        self.animProg = math.max( self.animProg - FrameTime() * 5, 0 )
    end
end

function SWEP:GetViewModelPosition( eyePos, eyeAng )
    eyeAng, eyePos = self.BaseClass.GetViewModelPosition( self, eyePos, eyeAng )

    self.animProg = self.animProg or 0

    eyePos.x = eyePos.x + self.animProg * 5
    eyePos.y = eyePos.y + self.animProg * 5

    return eyeAng, eyePos
end
