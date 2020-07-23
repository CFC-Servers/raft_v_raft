AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

function ENT:Initialize()
    self:SetMaxHealth( self.MaxHealth )
    self:SetHealth( self:GetMaxHealth() )
end

function ENT:OnTakeDamage( damageInfo )
    self:SetHealth( self:Health() - damageInfo:GetDamage() )

    local col = Lerp( self:Health() / self:GetMaxHealth(), 100, 255 )
    self:SetColor( Color( col, col, col ) )

    if self:Health() <= 0 then
        sound.Play( "physics/wood/wood_box_break1.wav", self:GetPos() )
        self:Remove()
    end
end
