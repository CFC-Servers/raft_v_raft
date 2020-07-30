AddCSLuaFile()
AddCSLuaFile( "cl_init.lua" )

SWEP.PrintName = "Repair tool"
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
SWEP.Cooldown = 0.04
SWEP.RepairAmount = 1
SWEP.ViewModel = "models/rvr/items/tape.mdl"
SWEP.WorldModel = "models/rvr/items/tape.mdl"

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end
