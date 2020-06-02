local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:GetHunger()
    return self:GetNWInt("rvr_hunger")
end

function PlayerMeta:SetHunger(n)
    self:SetNWInt("rvr_hunger", n)
end

function PlayerMeta:AddHunger(n)
    local hunger = self:GetNWInt("rvr_hunger")
    hunger = math.max( hunger+n, 0 )
    self:SetNWInt("rvr_hunger", hunger)
end


function PlayerMeta:GetThirst()
    return self:GetNWInt("rvr_thirst")
end

function PlayerMeta:SetThirst()
    self:SetNWInt("rvr_thirst")
end

function PlayerMeta:AddThirst(n)
    local thirst = self:GetNWInt("rvr_thirst")
    thirst = math.max( thirst + n, 0 )
    self:SetNWInt("rvr_thirst", thirst)
end


