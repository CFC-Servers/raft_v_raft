local function raftCommandCallback( ply )
    local ent = ents.Create("raft_foundation")
    ent:Spawn()
    ent:SetPos(ply:EyePos())
end

hook.Add("RVR_ModulesLoaded", "RvR_MakeRaftCommands", function()
    
    RVR.Commands.register( "create_raft", {}, {}, RVR_USER_SUPERADMIN, raftCommandCallback, "summon a raft" ) 
   -- RVR.Commands.register( "delete_raft", {"raftid"}, {"int"}, RVR_USER_SUPERADMIN, raftCommandCallback, "summon a raft" )
end)
