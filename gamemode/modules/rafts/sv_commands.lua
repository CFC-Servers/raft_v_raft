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

local function expandCallback( ply, class, x, y ,z, yaw )
    local ent = ply:GetEyeTrace().Entity
 
    if not IsValid( ent ) then return end
    local dir  = ent:ToPieceDir( Vector(x, y, z) )

    local err = RVR.expandRaft( ent, class, dir, Angle(0, yaw, 0))
    if err ~= nil then
        return "Couldn't place raft piece: "..err
    end
end

hook.Add("RVR_ModulesLoaded", "RvR_MakeRaftCommands", function()    
    RVR.Commands.register( "summon_raft", {}, {}, RVR_USER_SUPERADMIN, summonCommandCallback, "summon a raft" ) 
    RVR.Commands.register( "expand_raft", {"class", "x", "y", "z", "yaw"}, {"string", "int", "int", "int", "int"}, RVR_USER_SUPERADMIN, expandCallback, "expand a raft" )
end)
