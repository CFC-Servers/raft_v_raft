local function summonCommandCallback( ply )
    local trace = util.TraceLine{
        start  = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
        mask   = MASK_ALL,
        filter = ply,
    }

    local pos = trace.HitPos
    RVR.summonRaft( pos )
end

local function expandCallback( ply, piece, class, x, y ,z, yaw )
    local dir = piece:ToPieceDir( Vector(x, y, z) )

    local _, err = RVR.expandRaft( piece, class, dir, Angle(0, yaw, 0))
    if err ~= nil then
        return "Couldn't place raft piece: " .. err
    end
end

local function deleteCallback( ply, piece )
    piece:Remove()
end
hook.Add("RVR_ModulesLoaded", "RvR_MakeRaftCommands", function()    

    RVR.Commands.register( "summon_raft", {}, {}, RVR_USER_SUPERADMIN, summonCommandCallback, "summon a raft" ) 

    RVR.Commands.register( 
        "expand_raft",
        {"piece", "class", "x", "y", "z", "yaw"},
        {"entity", "string", "int", "int", "int", "int"},
        RVR_USER_SUPERADMIN,
        expandCallback,
        "expand a raft",
    )

    RVR.Commands.register( "rvr_delete_piece", {"piece"}, {"entity"}, RVR_USER_SUPERADMIN, deleteCallback, "delete a raft piece" )
end)
