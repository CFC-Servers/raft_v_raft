local function summonCommandCallback( ply )
    local trace = util.TraceLine{
        start  = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
        mask   = MASK_ALL,
        filter = ply,
    }

    local pos = trace.HitPos
    local raft = RVR.createRaft( pos )
    raft:AddOwnerID( ply:SteamID() )
end

local function expandCallback( ply, piece, class, x, y ,z, yaw )
    local raft = piece:GetRaft()
    if not raft:CanBuild( ply ) then 
        ply:PrintMessage( HUD_PRINTCONSOLE, "you do not have permissions to build on this raft" )
        return 
    end
    
    local success, itemsMissing = RVR.Inventory.tryTakeItems( 
        piece,  
        piece:GetRequiredItems()
    )
    if not success then
        -- TODO print itemsMissing in a human readable format
        ply:PrintMessage( HUD_PRINTCONSOLE, "missing required items" )
        return
    end
    
    local dir = Vector(x, y, z)
   
    local _, err = RVR.expandRaft( piece, class, dir, Angle(0, yaw, 0))
    if err ~= nil then
        return "Couldn't place raft piece: " .. err
    end
end

local function deleteCallback( ply, piece )
    piece:Remove()
end

local function listRafts( ply )
    for id, raft in pairs( RVR.raftLookup ) do
        ply:PrintMessage( HUD_PRINTCONSOLE, tostring(id)  )
    end
end

hook.Add("RVR_ModulesLoaded", "RvR_MakeRaftCommands", function()    

    RVR.Commands.register( "summon_raft", {}, {}, RVR_USER_SUPERADMIN, summonCommandCallback, "summon a raft" ) 

    RVR.Commands.register( 
        "expand_raft",
        {"piece", "class", "x", "y", "z", "yaw"},
        {"entity", "string", "int", "int", "int", "int"},
        RVR_USER_ALL,
        expandCallback,
        "expand a raft"
    )

    RVR.Commands.register( "delete_piece", {"piece"}, {"entity"}, RVR_USER_SUPERADMIN, deleteCallback, "delete a raft piece" )
    RVR.commands.register( "list_rafts", {}, {}, RVR_USER_ALL, listRafts, "list rafts in raftLookup table" )
end)
