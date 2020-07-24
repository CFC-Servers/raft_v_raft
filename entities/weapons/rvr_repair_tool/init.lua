include( "shared.lua" )

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Cooldown )

    local ent = self:GetOwner():GetEyeTrace().Entity
    if not ent.IsRaft and not ent.IsWall then return end

    if self:GetOwner():GetPartyID() ~= ent:GetRaft().partyID then return end

    if ent:Health() >= ent:GetMaxHealth() then return end

    ent:SetHealth( math.min( ent:Health() + self.RepairAmount, ent:GetMaxHealth() ) )
    self:LoseDurability()
end
