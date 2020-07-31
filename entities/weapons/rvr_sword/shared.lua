AddCSLuaFile()

SWEP.PrintName = "Sword"
SWEP.Author = "THE Gaft Gals ;)"
SWEP.HoldType = "melee"
SWEP.ViewModel = "models/rvr/items/sword.mdl"
SWEP.WorldModel = "models/rvr/items/sword.mdl"

--[[ TODO: Add model
SWEP.ViewModel = Model( "" )
SWEP.WorldModel = Model( "" )
]]

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1
SWEP.Primary.Damage = 60

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
function SWEP:Initialize()
    self:SetHoldType( "melee" )
end
local nextPrimaryFire = 0
function SWEP:PrimaryAttack()
    if CurTime() < nextPrimaryFire then return end
    nextPrimaryFire = CurTime() + self.Primary.Delay
 
    
    local owner = self:GetOwner()
    if not IsValid( owner ) then return end
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self.Weapon:SendWeaponAnim( ACT_RANGE_ATTACK1 )
    owner:LagCompensation( true )

    local aimVec = owner:GetAimVector()
    local traceStart = owner:GetShootPos()
    local traceEnd = traceStart + aimVec * 50

    local hBoxSize = Vector( 10, 10, 10 )

    local trace = util.TraceHull{
        start = traceStart,
        endpos = traceEnd,
        filter = owner,
        mask = MASK_SHOT_HULL,
        mins = -hBoxSize,
        maxs = hBoxSize
    }

    if not IsValid( trace.Entity ) then
        trace = util.TraceLine{
            start = traceStart,
            endpos = traceEnd,
            filter = owner,
            mask = MASK_SHOT_HULL
        }
    end

    local hitEnt = trace.Entity

    if trace.Hit then
        if SERVER then
            self:LoseDurability()
        end

        util.Decal("ManhackCut", trace.HitPos+trace.HitNormal, trace.HitPos-trace.HitNormal, self:GetOwner() )

        if IsValid( hitEnt ) then
            local eData = EffectData()
            eData:SetStart( traceStart )
            eData:SetOrigin( trace.HitPos )
            eData:SetNormal( trace.HitNormal )
            eData:SetEntity( hitEnt )

            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                util.Effect( "BloodImpact", eData )
            end

            if SERVER and trace.Hit and IsValid( hitEnt ) then
                local dmg = DamageInfo()
                dmg:SetDamage( self.Primary.Damage )
                dmg:SetAttacker( owner )
                dmg:SetInflictor( self )
                dmg:SetDamageForce( aimVec * 15 )
                dmg:SetDamageType( DMG_SLASH )

                hitEnt:DispatchTraceAttack( dmg, traceStart + aimVec * 3, traceEnd )
            end
        end
    end

    owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
end

function SWEP:DrawWorldModel()
    if not IsValid( self.Owner ) then return end

    local rightHandID = self.Owner:LookupAttachment("anim_attachment_rh")
    local rightHand = self.Owner:GetAttachment( rightHandID )

    local pos = rightHand.Pos + rightHand.Ang:Forward() * 1 + rightHand.Ang:Right()  + rightHand.Ang:Up()
    local ang = rightHand.Ang 

    self:SetRenderOrigin( pos )
    self:SetRenderAngles( ang )

    self:DrawModel()
end

function SWEP:GetViewModelPosition( eyePos, eyeAng )
    return eyePos + eyeAng:Right() * 5 + eyeAng:Forward() * 10 - eyeAng:Up() * 10 , eyeAng
end
