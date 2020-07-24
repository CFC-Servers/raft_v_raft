local function summonCommandCallback( ply )
    local partyID = ply:GetPartyID()
    if not partyID then return "You must be in a party" end

    local trace = util.TraceLine{
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 1000,
        mask = MASK_ALL,
        filter = ply
    }

    local pos = trace.HitPos
    local raft = RVR.Builder.createRaft( pos )

    raft:SetPartyID( partyID )
end

local function placeWallCallback( ply, piece, class, yaw )
    if yaw < 0 or yaw % 90 ~= 0 then return "Invalid yaw" end

    local raft = piece:GetRaft()
    local clsTable = baseclass.Get( class )
    if not clsTable.IsWall then return "You can only place walls" end

    if not raft then return end

    if not raft:CanBuild( ply ) then
        ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permission to build on this raft" )
        return
    end

    local required = clsTable:GetRequiredItems()

    local success, itemsMissing = RVR.Inventory.checkItems( ply.RVR_Inventory, required )
    if not success then
        -- TODO print itemsMissing in a human readable format
        ply:PrintMessage( HUD_PRINTCONSOLE, "missing required items" )
        return
    end

    local _, err = RVR.Builder.placeWall( piece, class, yaw )
    if err ~= nil then
        return "Couldn't place  wall: " .. err
    end

    RVR.Inventory.tryTakeItems( ply, required )
end

local function expandCallback( ply, piece, class, x, y, z, yaw )
    if yaw < 0 or yaw % 90 ~= 0 then return "Invalid yaw" end

    local raft = piece:GetRaft()
    if not raft then return end

    local clsTable = baseclass.Get( class )
    if not clsTable.IsRaft then return "You can only place raft pieces" end

    if not raft:CanBuild( ply ) then
        ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permissions to build on this raft" )
        return
    end
    local required = clsTable:GetRequiredItems()

    local success, itemsMissing = RVR.Inventory.checkItems( ply.RVR_Inventory, required )
    if not success then
        -- TODO print itemsMissing in a human readable format
        ply:PrintMessage( HUD_PRINTCONSOLE, "missing required items" )
        return
    end

    local dir = Vector( x, y, z )

    local _, err = RVR.Builder.expandRaft( piece, class, dir, Angle( 0, yaw, 0 ) )
    if err ~= nil then
        return "Couldn't place raft piece: " .. err
    end

    RVR.Inventory.tryTakeItems( ply, required )
end

local function placeItemCallback( ply, parentPiece, item, x, y, z, yaw )
    if not parentPiece.IsRaft then return end
    if not item.placeable then return end
    local raft = parentPiece:GetRaft()
    if not raft then return end

    if not raft:CanBuild( ply ) then
        ply:PrintMessage( HUD_PRINTCONSOLE, "You do not have permissions to build on this raft" )
        return
    end

    local required = {
        { item = item, count = 1 }
    }

    local success, itemsMissing = RVR.Inventory.checkItems( ply.RVR_Inventory, required )
    if not success then
        -- TODO print itemsMissing in a human readable format
        ply:PrintMessage( HUD_PRINTCONSOLE, "missing required items" )
        return
    end

    local pos = Vector( x, y, z )
    local angle = Angle( 0, yaw, 0 )
    -- TODO check that relativePos is at least near the parent piece

    RVR.Builder.placeItem( parentPiece, item, pos, angle )


    RVR.Inventory.tryTakeItems( ply, required )
end


local function deleteCallback( ply, piece )
    piece:Remove()
end

local function listRafts( ply )
    for id, raft in pairs( RVR.raftLookup ) do
        ply:PrintMessage( HUD_PRINTCONSOLE, tostring( id ) )
    end
end

hook.Add( "RVR_ModulesLoaded", "RvR_MakeRaftCommands", function()

    RVR.Commands.register( "summon_raft", {}, {}, RVR_USER_SUPERADMIN, summonCommandCallback, "Summon a raft" )

    RVR.Commands.register(
        "expand_raft",
        { "piece", "class", "x", "y", "z", "yaw" },
        { "entity", "string", "int", "int", "int", "int" },
        RVR_USER_ALL,
        expandCallback,
        "expand a raft"
    )

    RVR.Commands.register( "delete_piece", { "piece" }, { "entity" }, RVR_USER_SUPERADMIN, deleteCallback, "Delete a raft piece" )
    RVR.Commands.register( "list_rafts", {}, {}, RVR_USER_ALL, listRafts, "List rafts in raftLookup table" )
    RVR.Commands.register( "place_wall", { "piece", "class", "yaw" }, { "entity", "string", "int" }, RVR_USER_ALL, placeWallCallback, "Place a  wall" )

    RVR.Commands.register( 
        "place_item", 
        { "piece", "item", "x", "y", "z", "yaw" },
        { "entity", "item", "int", "int", "int", "int" },
        RVR_USER_ALL,
        placeItemCallback,
        "place an item on a raft"
    )
end )
