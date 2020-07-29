AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

DEFINE_BASECLASS( "raft_breakable_base" )

function ENT:Initialize()
    BaseClass.Initialize( self )

    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( false )
    end
end

function ENT:OnRemove()
    if self._removing then return end
    self._removing = true

    local raft = self:GetRaft()
    if not raft then return end
    local neighbors = raft:GetNeighbors( self )

    for _, ent in pairs( neighbors ) do
        if IsValid( ent ) and not ent._removing and not ent:ShouldExist() then
            ent:Remove()
        end
    end

    if self.walls then
        for _, wall in pairs( self.walls ) do
            wall:Remove()
        end
    end

    raft:RemovePiece( self )
end

-- should the raft piece still exist e.g. a platform must have a foundation bellow it
function ENT:ShouldExist()
    return true
end

function ENT:PhysicsSimulate( phys, deltaTime )
end
