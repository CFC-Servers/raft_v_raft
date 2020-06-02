local config = GM.Config.Hunger

local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:GetFood()
    return self:GetNWInt( "rvr_food" )
end

function PlayerMeta:SetFood( n )
    self:SetNWInt( "rvr_food", n )
end

function PlayerMeta:AddFood( n )
    local food = self:GetNWInt( "rvr_food" )
    food = math.Clamp( food + n, 0, config.MAX_FOOD )
    self:SetNWInt( "rvr_food", food )
end


function PlayerMeta:GetWater()
    return self:GetNWInt( "rvr_water" )
end

function PlayerMeta:SetWater( n )
    self:SetNWInt( "rvr_water", n )
end

function PlayerMeta:AddWater(n)
    local water = self:GetNWInt( "rvr_water" )
    water = math.Clamp( water + n, 0, config.MAX_WATER )
    self:SetNWInt( "rvr_water", water )
end

