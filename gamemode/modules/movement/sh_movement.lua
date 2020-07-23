local function isEmptyPos( ply, pos )
    local mins, maxs = ply:GetCollisionBounds()

    local trace = util.TraceHull{
        start = pos,
        endpos = pos,
        filter = ply,
        mins = mins,
        maxs = maxs,
        mask = MASK_PLAYERSOLID
    }
    return not trace.Hit
end

local function calculateStepPos( ply, pos )
    local mins, maxs = ply:GetCollisionBounds()

    if not isEmptyPos( ply, pos ) then 
        local trace = util.TraceHull{
            start = pos + vector_up * ply:GetStepSize(),
            endpos = pos,
            filter = ply,
            mins = mins,
            maxs = maxs,
            mask = MASK_PLAYERSOLID
        }
        
        -- player is stuck
        if trace.StartSolid then return nil end
        -- player is floating
        if not trace.Hit then return nil end
        
        return tr.HitPos
    end

    local trace = util.TraceHull{
        start = pos,
        endpos = pos - vector_up * ply:GetStepSize(),
        filter = ply,
        mins = mins,
        maxs = maxs,
        mask = MASK_PLAYERSOLID
    }

    return trace.HitPos
end

local function tryMove( ply, pos, vel )
    local pos = calculateStepPos( ply, pos + vel * FrameTime() )
    if not pos then return nil end

    if not isEmptyPos( ply, pos ) then return nil end

    return pos
end

function GM:SetupMove( ply, mv , cmd )
    local ang = cmd:GetViewAngles()
    ang.pitch = 0
    ang.roll = 0

    ply.RVRMovement = ang:Forward() * cmd:GetForwardMove() + ang:Right() * cmd:GetSideMove()
    
    local speed = ply.RVRAccel:Length() * FrameTime()
    
    ply.RVRMovement:Normalize()
    
    if ply:Crouching() then
        speed:Mul( ply:GetCrouchedWalkSpeed() )
    end

    ply.RVRAccel:Mul( speed ) 
end

function GM:FinishMove( ply, mv )
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    
    local ground = ply:GetGroundEntity()
    if not IsValid( ground ) then return end
    if not ground.IsRaft then return end

    mv:SetVelocity( ground:GetVelocity() )

    local pos = ply:GetPos() 
    
    -- Why am i dividing this by 2?
    pos = TryMove( ply, pos, mv:GetVelocity() / 2 + ply.RVRAccel )
    
    ply:SetLocalVelocity( ground:GetVelocity() )
	ply:SetAbsVelocity( ground:GetVelocity() )
	ply:SetLocalAngles( ground:GetAngles() )
    
    if not pos then return true end

    pos.z = math.ceil(pos.z)      
    
    ply:SetPos( pos )
    ply:SetLocalPos( pos )
    ply:SetNetworkOrigin( pos )
    mv:SetOrigin( pos ) 

    return true
end
