
SWEP.Author         = "CFC"
SWEP.Base           = "weapon_base"
SWEP.ViewModel      = ""
SWEP.Category       = "RVR"
SWEP.Spawnable      = false

SWEP.Primary.Sound  = Sound( "Weapon_Pistol.Empty" )
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 1
SWEP.Primary.Delay  = 0.15


function SWEP:PrimaryAttack()
    self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

    if not self:CanPrimaryAttack() then return end
end