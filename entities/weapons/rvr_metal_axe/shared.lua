AddCSLuaFile()

SWEP.PrintName = "Metal Axe"
SWEP.Base = "rvr_wooden_axe"
SWEP.ViewModel = "models/rvr/items/metal_axe.mdl"
SWEP.WorldModel = "models/rvr/items/metal_axe.mdl"
SWEP.Primary.Damage = 45


function SWEP:DrawWorldModel()
    if not IsValid( self.Owner ) then return end

    local rightHandID = self.Owner:LookupAttachment( "anim_attachment_rh" )
    local rightHand = self.Owner:GetAttachment( rightHandID )

    local pos = rightHand.Pos + rightHand.Ang:Forward() - rightHand.Ang:Right() * 2 + rightHand.Ang:Up() * 7
    local ang = rightHand.Ang + Angle( 0, 90, 0 )

    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )

    self:DrawModel()
end

function SWEP:GetViewModelPosition( eyePos, eyeAng )
    eyePos = eyePos + eyeAng:Right() * 5 + eyeAng:Forward() * 10 - eyeAng:Up() * 10
    local timeSince = math.max( self.lastAttacked + 0.1 - CurTime(), 0 )
    local pitch = Lerp( timeSince / 0.1, 0, 60 )
    -- TODO cleanup code
    eyeAng = eyeAng + Angle( pitch, 90, pitch )
    return eyePos, eyeAng
end
