include("shared.lua")
local nextPrimary = 0

function SWEP:PrimaryAttack()
    if CurTime() <= nextPrimary then return end
    nextPrimary = CurTime() + 0.5
    local trace = self:DoPaddleTrace()
    if not trace.Hit then return end

    local effectdata = EffectData()
    effectdata:SetOrigin( trace.HitPos )
    effectdata:SetScale( 5 )
    util.Effect( "watersplash", effectdata )
end
