AddCSLuaFile()

SWEP.PrintName = "Binoculars"
SWEP.Author = "THE Gaft Gals ;)"

SWEP.ViewModel = ""
SWEP.WorldModel = "models/rvr/items/binoculars.mdl"

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false

SWEP.Zoomed = false


SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

hook.Add( "PlayerConnected", "RVR_Binoculars_disableZoom", function( ply )
    ply:SetCanZoom( false )
end )

function SWEP:Initialize()
    self:SetWeaponHoldType( "camera" )
end

function SWEP:PrimaryAttack()
end

function SWEP:DrawWorldModel()
    self:DrawModel()
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if CLIENT and owner ~= LocalPlayer() then return end
    if not IsFirstTimePredicted() then return end

    local cmd = owner:GetCurrentCommand()
    if not cmd:KeyDown( IN_ATTACK2 ) then return end

    self.Zoomed = not self.Zoomed

    self:SetZoom( self.Zoomed )
    self:SetNextSecondaryFire( CurTime() + 0.3 )
end

function SWEP:SetZoom( state )
    local owner = self:GetOwner()
    if not ( IsValid( owner ) and owner:IsPlayer() ) then return end

    if state then
        owner:SetFOV( 20, 0.3 )
    else
        owner:SetFOV( 0, 0.2 )
    end
end

function SWEP:Holser()
    if SERVER then return end

    self:SetZoom( false )
end

function SWEP:OnRemove()
    if SERVER then return end

    self:SetZoom( false )
end

function SWEP:AdjustMouseSensitivity()
    -- TODO: Adjust this so the sensitivity can never be inverted
    return self.Zoomed and 0.2 or nil
end

function SWEP:DrawWorldModel()
    if not IsValid( self.Owner ) then return end

    local rightHandID = self.Owner:LookupAttachment( "anim_attachment_rh" )
    local rightHand = self.Owner:GetAttachment( rightHandID )

    local pos = rightHand.Pos + rightHand.Ang:Forward() * 3 + rightHand.Ang:Right() * -2.7 + rightHand.Ang:Up() * 3.6
    local ang = rightHand.Ang + Angle( 180, 0, 170 )

    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )

    self:DrawModel()
end
