local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:GetFood()
    return self:GetNWInt("rvr_food")
end

function PlayerMeta:SetFood(n)
    self:SetNWInt("rvr_food", n)
end

function PlayerMeta:AddFood(n)
    local food = self:GetNWInt("rvr_food")
    food = math.max( food+n, 0 )
    self:SetNWInt("rvr_food", food)
end


function PlayerMeta:GetWater()
    return self:GetNWInt("rvr_water")
end

function PlayerMeta:SetWater()
    self:SetNWInt("rvr_water")
end

function PlayerMeta:AddWater(n)
    local water = self:GetNWInt("rvr_water")
    water = math.max( thirst + n, 0 )
    self:SetNWInt("rvr_water", thirst)
end


