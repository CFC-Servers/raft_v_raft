AddCSLuaFile()

SWEP.PrintName = "Sword"
SWEP.Base = "rvr_melee_base"
SWEP.ViewModel = "models/rvr/items/sword.mdl"
SWEP.WorldModel = "models/rvr/items/sword.mdl"


function SWEP:DrawWorldModel()
    if not IsValid( self.Owner ) then return end

    local rightHandID = self.Owner:LookupAttachment( "anim_attachment_rh" )
    local rightHand = self.Owner:GetAttachment( rightHandID )

    local pos = rightHand.Pos + rightHand.Ang:Forward() * 1 + rightHand.Ang:Right() + rightHand.Ang:Up()
    local ang = rightHand.Ang

    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )

    self:DrawModel()
end
