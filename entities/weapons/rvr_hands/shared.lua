AddCSLuaFile()

SWEP.PrintName = "Hands"
SWEP.Author = "CFC Dev Team"

SWEP.WorldModel = Model( "" )

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Primary.Ammo = ""
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetWeaponHoldType( "normal" )
end

function SWEP:Deloy()
    if SERVER and IsValid( self:GetOwner() ) then
        self:GetOwner():DrawViewModel( false )
    end

    self:DrawShadow( false )

    return false
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:OnDrop()
    self:Remove()
end

function SWEP:ShouldDropOnDie()
    return false
end

function SWEP:ShouldDrawViewModel()
    return false
end
