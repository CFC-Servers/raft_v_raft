AddCSLuaFile()

SWEP.PrintName = "Tape"
SWEP.Author = "CFC Dev Team"

--[[ TODO: Add model
SWEP.ViewModel = Model( "" )
SWEP.WorldModel = Model( "" )
]]

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo = ""

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Secondary.Ammo = ""

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

    local tr = util.TraceLine{
        start = traceStart,
        endpos = traceEnd,
        filter = owner,
        mask = MASK_SHOT_HULL
    }

    local hitEnt = tr.Entity

    if IsValid( hitEnt ) then
        if SERVER then
            self:LoseDurability()
        end

        -- TODO: Add repairing stuff
        print( ":)" )
    end

    owner:LagCompensation( false )
end

function SWEP:SecondaryAttack()
end