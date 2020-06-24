AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:ShouldExist()
    local raft = self:GetRaft()
    local pos = raft:GetPosition( self )

    local supportingPiece = raft:GetPiece( pos + Vector(-1, 0, 0))
    if not supportingPiece then return false end
    
    local className = supportingPiece:GetClass()

    if className == "raft_foundation" then return true end
    if className == "raft_platform" then return true end
    
    return false 
end
