local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:GetHunger()
    return self:GetNWInt("rvr_hunger")
end

function PlayerMeta:SetHunger(n)
    self:SetNWInt("rvr_hunger", n)
end

function PlayerMeta:AddHunger(n)
    local hunger = self:GetNWInt("rvr_hunger")
    hunger = math.max( hunger, 0 )
    self:SetNWInt("rvr_hunger", hunger + n)
end

