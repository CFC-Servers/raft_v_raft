AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/Gibs/wood_gib01b.mdl" )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        phyObj:Wake()
    end
end
