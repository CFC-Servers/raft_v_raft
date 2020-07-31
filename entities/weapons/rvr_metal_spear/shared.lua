AddCSLuaFile()

SWEP.PrintName = "Metal Spear"
SWEP.Base = "rvr_melee_base"
SWEP.HoldType = "knife"
SWEP.ViewModel = "models/rvr/items/metal_spear.mdl"
SWEP.WorldModel = "models/rvr/items/metal_spear.mdl"
SWEP.Primary.Damage = 55
SWEP.AttackRange = 100
function SWEP:GetViewModelPosition( eyePos, eyeAng )
    eyePos = eyePos + eyeAng:Right() * 5 + eyeAng:Forward() * 10 - eyeAng:Up() * 10
    eyeAng = eyeAng + Angle( 90, 0, 0 )
    local timeSince = math.max( self.lastAttacked + 0.3 - CurTime(), 0 )
    local y = Lerp( timeSince / 0.3, 0, 40 ) - 20
    eyePos = eyePos + eyeAng:Up() * y
    return eyePos, eyeAng
end

function SWEP:DrawWorldModel()
    if not IsValid( self.Owner ) then return end

    local rightHandID = self.Owner:LookupAttachment( "anim_attachment_rh" )
    local rightHand = self.Owner:GetAttachment( rightHandID )

    local pos = rightHand.Pos + rightHand.Ang:Right() - rightHand.Ang:Up() * 30

    local ang = rightHand.Ang

    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )

    self:DrawModel()
end
