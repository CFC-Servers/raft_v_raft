local config = GM.Config.Hunger

hook.Add( "PlayerSpawn", "RaftVRaft_HungerReset", function( ply, transition )
    ply:SetFood( config.MAX_FOOD )
    ply:SetWater( config.MAX_WATER )
end )

local function hungerThink()
    for _, ply in pairs( player.GetHumans() ) do
        local shouldLoseHunger = math.random() <= config.LOSS_CHANCE
        if shouldLoseHunger then
            ply:AddFood( config.FOOD_LOSS_AMOUNT )
            ply:AddWater( config.WATER_LOSS_AMOUNT )
        end
    end
end

local function hungerDamageThink()
    for  _, ply in  pairs( player.GetHumans() ) do
        local damage = 0

        if ply:GetFood() <= 0 then
            damage = damage + config.DAMAGE_AMOUNT
        end

        if ply:GetWater() <= 0 then
            damage = damage + config.DAMAGE_AMOUNT
        end

        if damage > 0 then
            ply:TakeDamage( damage )
        end
    end
end

timer.Create( "rvr_hunger_loss", config.DELAY, 0, hungerThink )
timer.Create( "rvr_hunger_damage", config.DAMAGE_DELAY, 0, hungerDamageThink )

local PlayerMeta = FindMetaTable( "Player" )

function PlayerMeta:SetFood( n )
    self:SetNWInt( "rvr_food", n )
end

function PlayerMeta:AddFood( n )
    local food = self:GetNWInt( "rvr_food" )
    food = math.Clamp( food + n, 0, config.MAX_FOOD )

    self:SetNWInt( "rvr_food", food )
end

function PlayerMeta:SetWater( n )
    self:SetNWInt( "rvr_water", n )
end

function PlayerMeta:AddWater( n )
    local water = self:GetNWInt( "rvr_water" )
    water = math.Clamp( water + n, 0, config.MAX_WATER )

    self:SetNWInt( "rvr_water", water )
end
