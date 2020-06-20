include("shared.lua")

function SWEP:PrimaryAttack()
    local ent = self:GetAimEntity()
    local dir = self:GetPlacementDirection()
    if not (dir and ent) then return end
    
    RVR.expandRaft( ent, {
        dir = dir,
        class = "raft_foundation",
    })
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

