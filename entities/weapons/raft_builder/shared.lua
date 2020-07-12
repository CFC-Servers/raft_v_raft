AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

SWEP.PrintName = "Raft Builder"
SWEP.HoldType = "melee"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crwobar.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.Placeables = {
    {
        class = "raft_foundation",
    },
    {
        class = "raft_platform",
    },
    {
        class = "raft_stairs",
    },
    {
        class = "raft_wall",
    },
    {
        class = "raft_fence",
    },
}
