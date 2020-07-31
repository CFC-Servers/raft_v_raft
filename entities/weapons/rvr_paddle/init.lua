AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )
function SWEP:PrimaryAttack() 
    local trace = self:DoPaddleTrace()

    if not trace.Hit then return end

    local vel = self:GetOwner():GetAimVector()
    vel.z = 0

    local ground = self:GetOwner():GetGroundEntity()

    if not ground or not ground.IsRaft then return end

    local raft = ground:GetRaft()
    if not raft then return end

    raft:AddPaddleMovement( vel * GAMEMODE.Config.Rafts.PADDLE_FORCE )
end
