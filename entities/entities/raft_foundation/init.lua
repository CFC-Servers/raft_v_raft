AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "raft_piece_base" )

function ENT:OnRemove()
    BaseClass.OnRemove( self )

    local raft = self:GetRaft()
    if not raft then return end
    local neighbors = raft:GetNeighbors( self )

    for _, ent in pairs( neighbors ) do
        local relativePos = self:GetRaftGridPosition() - ent:GetRaftGridPosition()
        if relativePos:Length() > 1 then continue end

        print( ent, relativePos )
    end

    PrintTable( neighbors )
end
