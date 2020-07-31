SWEP.PrintName = ""
SWEP.Author = "THE Gaft Galls ;)"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = ""
SWEP.PaddleRange = 100

function SWEP:DoPaddleTrace()
    local owner = self:GetOwner()
    local traceData = util.GetPlayerTrace( owner )
    traceData.endpos = traceData.start + owner:GetAimVector() * self.PaddleRange
    traceData.mask = MASK_WATER
    local trace = util.TraceLine( traceData )

    return trace
end
