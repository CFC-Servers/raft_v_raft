local vectorUp = Vector( 0, 0, 1 )

local function isEmptyPos( ply, pos )
    local mins, maxs = ply:GetCollisionBounds()

    local filter = player.GetAll()

    local trace = util.TraceHull{
        start = pos,
        endpos = pos,
        filter = filter,
        mins = mins,
        maxs = maxs,
        mask = MASK_PLAYERSOLID
    }

    return not trace.Hit
end

local function getGroundIfRaft( ply )
    local ground = ply:GetGroundEntity()

    if CLIENT and not IsValid( ground ) and ply ~= LocalPlayer() then
        local pos = ply:GetPos()

        local trace = util.TraceLine{
            start = pos,
            endpos = pos + Vector( 0, 0, -5 ),
            filter = ply,
            mask = MASK_PLAYERSOLID
        }

        if trace.Hit then
            ground = trace.Entity
        end
    end

    if not IsValid( ground ) then return end
    if not ground.IsRaft then return end

    return ground
end

local function calculateStepPos( ply, pos )
    local mins, maxs = ply:GetCollisionBounds()

    local filter = player.GetAll()

    if not isEmptyPos( ply, pos ) then
        local trace = util.TraceHull{
            start = pos + vectorUp * ply:GetStepSize(),
            endpos = pos,
            filter = filter,
            mins = mins,
            maxs = maxs,
            mask = MASK_PLAYERSOLID
        }

        -- player is stuck
        if trace.StartSolid then return end
        -- player is floating
        if not trace.Hit then return end

        return trace.HitPos
    end

    local trace = util.TraceHull{
        start = pos,
        endpos = pos - vectorUp * ply:GetStepSize(),
        filter = filter,
        mins = mins,
        maxs = maxs,
        mask = MASK_PLAYERSOLID
    }

    return trace.HitPos
end

local function tryMove( ply, pos, vel )
    pos = calculateStepPos( ply, pos + vel * FrameTime() )
    if not pos then return end

    if not isEmptyPos( ply, pos ) then return end

    return pos
end

function GM:SetupMove( ply, mv, cmd )
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
        ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
        return
    end

    local ground = getGroundIfRaft( ply )
    if not ground then
        ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
        return
    end

    mv:SetVelocity( ground:GetVelocity() )

    local pos = tryMove( ply, ply:GetPos(), ply.RVRMovement + mv:GetVelocity() )

    ply:SetLocalVelocity( ply.RVRMovement )
    ply:SetAbsVelocity( ply.RVRMovement )
    ply:SetLocalAngles( ground:GetAngles() )

    if not pos then
        ply:SetCollisionGroup( COLLISION_GROUP_PASSABLE_DOOR )
        return true
    end

    ply:SetCollisionGroup( COLLISION_GROUP_WORLD )
    ply:SetPos( pos )
    ply:SetLocalPos( pos )
    ply:SetNetworkOrigin( pos )
    mv:SetOrigin( pos )

    return true
end

local positionCache = {}
plyVels = {}

local timerDelay = 0.05

timer.Create( "RVR_Player_Vel", timerDelay, 0, function()
    for _, ply in pairs( player.GetAll() ) do
        local plyPos = ply:GetPos()

        if not positionCache[ply] then
            positionCache[ply] = plyPos
        end

        local plyVel = ( plyPos - positionCache[ply] ) / timerDelay

        plyVels[ply] = plyVel

        positionCache[ply] = plyPos
    end
end )

hook.Add( "PrePlayerDraw", "RVR_Anti_Interpolation", function( ply )
    local ground = getGroundIfRaft( ply )
    if not ground then return end

    local plyVel = plyVels[ply] or Vector( 0, 0, 0 )

    local vel = ( plyVel - ground:GetVelocity() ):GetNormalized()

    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0

    local move_x, move_y = vel:Dot( ang:Forward() ), vel:Dot( ang:Right() )
    local maxMoveSpeed = ply:GetSequenceGroundSpeed( ply:GetSequence() )

    move_x = ( move_x + 1 ) / 2
    move_y = ( move_y + 1 ) / 2

    if maxMoveSpeed <= 1 then
        maxMoveSpeed = 1
    end

    --print( move_x)
    local newMoveX = move_x * ply:GetPlaybackRate() / maxMoveSpeed
    local newMoveY = move_y * ply:GetPlaybackRate() / maxMoveSpeed

    ply:SetPoseParameter( "move_x", newMoveX )
    ply:SetPoseParameter( "move_y", newMoveY )

    ply:InvalidateBoneCache()
    ply:SetupBones()

    local wep = ply:GetActiveWeapon()

    if IsValid( wep ) then
        wep:InvalidateBoneCache()
        wep:SetupBones()
    end
end )

hook.Add( "DoAnimationEvent", "RVR_DoAnimationEvent", function( ply, event, data )
    print(event)
end )