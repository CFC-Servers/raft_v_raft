AddCSLuaFile()

SWEP.PrintName = "Hands"
SWEP.Author = "CFC Dev Team"

SWEP.ViewModel = Model( "" )
SWEP.WorldModel = Model( "" )

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

function SWEP:Initialize()
    self:SetWeaponHoldType( "normal" )
end

function SWEP:Deloy()
    if SERVER and IsValid( self:GetOwner() ) then
        self:GetOwner():DrawViewModel( false )
    end

    self:DrawShadow( false )

    return true
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

