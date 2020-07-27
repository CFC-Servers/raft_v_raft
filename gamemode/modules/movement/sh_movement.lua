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

local function getGroundIfRaft( ply )
    local ground = ply:GetGroundEntity()

    if not IsValid( ground ) then return end
    if not ground.IsRaft then return end

    return ground
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

        return trace.HitPos
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

    local speed = ply.RVRMovement:Length() * FrameTime()

    ply.RVRMovement:Normalize()

    if ply:Crouching() then
        speed = speed * ply:GetCrouchedWalkSpeed()
    elseif ply:IsSprinting() then
        speed = speed * 2
    end
    ply.RVRMovement:Mul( speed )
end

function GM:FinishMove( ply, mv )
    if ply:GetMoveType() == MOVETYPE_NOCLIP then
        ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        ply.lastMovedBase = nil
        return
    end

    local ground = getGroundIfRaft( ply )
    if not ground then
        ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
        ply.lastMovedBase = nil
        return
    end

    mv:SetVelocity( ground:GetVelocity() )

    local pos
    if ply.lastMovedBase and ply.RVRMovement:IsZero() and ply.lastMoved and ply.lastMoved + 1 <= CurTime() then
        targetPos = ply.lastMovedBase:LocalToWorld( ply.lastMovedPos )
        local movement = targetPos - ply:GetPos()
        pos = tryMove( ply, ply:GetPos(), movement ) or targetPos
    else
        pos = tryMove( ply, ply:GetPos(), ply.RVRMovement + mv:GetVelocity() )

        ply.lastMoved = CurTime()
        ply.lastMovedBase = ground
        ply.lastMovedPos = ground:WorldToLocal( ply:GetPos() )
    end

    ply:SetLocalVelocity( ply.RVRMovement )
    ply:SetAbsVelocity( ply.RVRMovement )
	ply:SetLocalAngles( ground:GetAngles() )

    if not pos then return end
    ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
    ply:SetPos( pos )
    ply:SetLocalPos( pos )
    ply:SetNetworkOrigin( pos )
    mv:SetOrigin( pos )

    return true
end
