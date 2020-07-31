AddCSLuaFile()

SWEP.PrintName = "Stone Spear"
SWEP.Base = "rvr_melee_base"
SWEP.ViewModel = "models/rvr/items/stone_spear.mdl"
SWEP.WorldModel = "models/rvr/items/stone_spear.mdl"
SWEP.Primary.Damage = 40
SWEP.AttackRange = 100
function SWEP:GetViewModelPosition( eyePos, eyeAng )
    eyePos = eyePos + eyeAng:Right() * 5 + eyeAng:Forward() * 10 - eyeAng:Up() * 10
    eyeAng = eyeAng + Angle( 90, 0, 0 )
    local timeSince = math.max( self.lastAttacked + 0.3 - CurTime(), 0 )
    local y =  Lerp( timeSince / 0.3, 0, 40 ) - 20
    eyePos = eyePos + eyeAng:Up() * y
    return eyePos, eyeAng
end
