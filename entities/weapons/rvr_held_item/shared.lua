SWEP.PrintName = "<held_item>"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "None"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"
SWEP.BobScale = 0.1
SWEP.SwayScale = 0
SWEP.DrawAmmo = false

function SWEP:SetupDataTables()
    self:NetworkVar( "String", 0, "ItemModel" )
    self:NetworkVar( "Angle", 0, "ViewModelAng" )
    self:NetworkVar( "Vector", 0, "ViewModelOffset" )

    self:NetworkVar( "Angle", 1, "WorldModelAng" )
    self:NetworkVar( "Vector", 1, "WorldModelOffset" )
end

function SWEP:Initialize()
    self:SetWeaponHoldType( "melee" )

    if not CLIENT then return end

    -- Set up network var listener to update model when ItemModel set
    self:NetworkVarNotify( "ItemModel", function( this, _, _, mdl )
        this.WorldModel = mdl

        if not IsValid( self.WorldModelEnt ) then
            self.WorldModelEnt = ClientsideModel( self.WorldModel )
            if self.WorldModelEnt then
                self.WorldModelEnt:SetNoDraw( true )
            end
        else
            self.WorldModelEnt:SetModel( mdl )
        end
    end )
end

-- Empty to remove default behaviour, don't remove >:(
function SWEP:PrimaryAttack()
end
