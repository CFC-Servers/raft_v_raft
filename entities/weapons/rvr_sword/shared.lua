AddCSLuaFile()

SWEP.PrintName = "Sword"
SWEP.Author = "CFC Dev Team"

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

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

    local owner = self:GetOwner()
    if not IsValid( owner ) then return end

    owner:LagCompensation( true )

    local aimVec = owner:GetAimVector()
    local traceStart = owner:GetShootPos()
    local traceEnd = traceStart + ( aimVec * 50 )

    local hBoxSize = Vector( 10, 10, 10 )

    local tr = util.TraceHull{
        start = traceStart,
        endpos = traceEnd,
        filter = owner,
        mask = MASK_SHOT_HULL,
        mins = -hBoxSize,
        maxs = hBoxSize
    }

    if not IsValid( tr.Entity ) then
        tr = util.TraceLine{
            start = traceStart,
            endpos = traceEnd,
            filter = owner,
            mask = MASK_SHOT_HULL
        }
    end

    local hitEnt = tr.Entity

    if tr.Hit then
        if SERVER then
            self:LoseDurability()
        end

        if IsValid( hitEnt ) then
            local eData = EffectData()
            eData:SetStart( traceStart )
            eData:SetOrigin( tr.HitPos )
            eData:SetNormal( tr.HitNormal )
            eData:SetEntity( hitEnt )

            if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
                util.Effect( "BloodImpact", eData )
            end

            if SERVER and tr.Hit and tr.HitNonWorld and hitEnt:IsPlayer() then
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
