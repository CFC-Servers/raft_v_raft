local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:GetFood()
    return self:GetNWInt( "rvr_food" )
end

function PlayerMeta:GetWater()
    return self:GetNWInt( "rvr_water" )
end
