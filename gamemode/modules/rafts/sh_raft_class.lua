local raftMeta = {}
raftMeta.__index = raftMeta

local party = RVR.Party

function raftMeta:AddPiece( position, ent )
    ent:SetRaftGridPosition( position )
    self.pieces[ent:EntIndex()] = ent
    self.grid[self.vectorIndex( position )] = ent

    if not self:GetParty() then return end

    net.Start( "RVR_Raft_NewRaftPiece" )
        net.WriteInt( self.id, 32 )
        net.WriteInt( ent:EntIndex(), 32 )
        net.WriteVector( position )
    net.Send( self:GetParty().members )
end

function raftMeta:Remove()
    self.removing = true
    RVR.removeRaft( self.id )
end

function raftMeta:GetPiece( position )
    local ent = self.grid[self.vectorIndex( position )]
    if not ent then return end

    local index = ent:EntIndex()

    if not IsValid( ent ) or not self.pieces[index] then
        self.pieces[index] = nil
        self.grid[self.vectorIndex( position )] = nil
        return
    end

    return ent
end

function raftMeta:GetAveragePosition()
    local totalPos = Vector()
    for _, raftPiece in pairs( self.pieces ) do
        totalPos = totalPos + raftPiece:GetPos()
    end

    return totalPos / table.Count( self.pieces )
end

function raftMeta:GetNeighbors( piece )
    local neighbors = {}

    for x = -1, 1 do
        for y = -1, 1 do
            for z = -1, 1 do
                local dir = Vector( x, y, z )

                if not dir:IsZero() then
                    local pos = self:GetPosition( piece ) + dir
                    local piece = self:GetPiece( pos )
                    if IsValid( piece ) then
                        table.insert( neighbors, piece )
                    end
                end
            end
        end
    end

    return neighbors
end

function raftMeta:GetPosition( piece )
    return piece:GetRaftGridPosition()
end

local config = ( GAMEMODE or GM ).Config.Rafts

local function getValidSpawnPos( ply, raftPiece, plyMins, plyMaxs )
    if not IsValid( raftPiece ) then return end

    if not config.SPAWNPOINT_PARTS[raftPiece:GetClass()] then return end

    local size = raftPiece:OBBMaxs() - raftPiece:OBBMins()
    local center = raftPiece:OBBCenter()
    local top = raftPiece:GetPos() + center + Vector( 0, 0, size.z * 0.5 + 1 )

    local traceResult = util.TraceHull {
        start = top,
        endpos = top,
        filter = ply,
        mins = plyMins,
        maxs = plyMaxs,
        mask = MASK_PLAYERSOLID
    }

    if not traceResult.Hit then
        return top
    end
end

-- Attempts to find a spawnable part that can fit a player on, else spawns significantly above the highest part
function raftMeta:GetSpawnPosition( ply )
    local mins, maxs = ply:GetCollisionBounds()
    local _, highestPiece = next( self.pieces )

    for _, raftPiece in pairs( self.pieces ) do
        local pos = getValidSpawnPos( ply, raftPiece, mins, maxs )
        if pos then return pos end

        if not IsValid( raftPiece ) and raftPiece:GetPos().z > highestPiece:GetPos().z then
            highestPiece = raftPiece
        end
    end

    return highestPiece:GetPos() + Vector( 0, 0, 100 )
end

-- ownership
function raftMeta:GetParty()
    if not self.partyID then return end
    return party.getParty( self.partyID )
end

function raftMeta:SetParty( partyData )
    self.partyID = partyData.ID
end

function raftMeta:SetPartyID( partyID )
    self.partyID = partyID

    if not SERVER then return end

    net.Start( "RVR_Raft_SetPartyID" )
        net.WriteInt( self.id, 32 )
        net.WriteInt( partyID, 32 )
    net.Broadcast()
end

function raftMeta:CanBuild( ply )
    if ply:IsAdmin() then return true end

    return ply:GetPartyID() == self.partyID
end

function raftMeta:RemovePiece( piece )
    if self.removing then return end
    self.pieces[piece:EntIndex()] = nil

    if table.IsEmpty( self.pieces ) then
        self:Remove()
        return
    end

    if piece:GetClass() ~= "raft_foundation" then return end

    if piece.removedByRaft then return end

    local grid, piecesGrid = self:GetSegmentingGrid()

    local segments = RVR.Util.segmentGrid( grid )

    if #segments <= 1 then return end

    local maxSize = 0
    local biggestIdx

    for k, segment in pairs( segments ) do
        if #segment > maxSize then
            maxSize = #segment
            biggestIdx = k
        end
    end

    local piecePos = piece:GetRaftGridPosition()

    for k, segment in pairs( segments ) do
        if k == biggestIdx then continue end
        for _, pos in pairs( segment ) do
            local ent = piecesGrid[pos.y][pos.x]

            local entPos = ent:GetRaftGridPosition()

            local gridDist = math.abs( piecePos.x - entPos.x ) + math.abs( piecePos.y - entPos.y )

            ent.removedByRaft = true

            ent:SetRemoveTime( gridDist * 0.2 )
        end
    end
end

function raftMeta:GetSegmentingGrid()
    if table.IsEmpty( self.pieces ) then return {} end

    local pieceGrid = {}

    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge

    for _, piece in pairs( self.pieces ) do
        if not IsValid( piece ) then continue end
        if piece:GetClass() ~= "raft_foundation" then continue end

        local gridPos = piece:GetRaftGridPosition()
        pieceGrid[gridPos.y] = pieceGrid[gridPos.y] or {}
        pieceGrid[gridPos.y][gridPos.x] = piece

        if gridPos.x < minX then
            minX = gridPos.x
        end
        if gridPos.x > maxX then
            maxX = gridPos.x
        end

        if gridPos.y < minY then
            minY = gridPos.y
        end
        if gridPos.y > maxY then
            maxY = gridPos.y
        end
    end

    local grid = {}
    local adjustedPieceGrid = {}
    for y = minY, maxY do
        local gridY = y - minY + 1

        grid[gridY] = {}
        adjustedPieceGrid[gridY] = {}

        for x = minX, maxX do
            local gridX = x - minX + 1

            local piece = pieceGrid[y] and pieceGrid[y][x]
            grid[gridY][gridX] = piece ~= nil
            adjustedPieceGrid[gridY][gridX] = piece
        end
    end

    return grid, adjustedPieceGrid
end

-- util
function raftMeta.vectorIndex( v )
    -- hopefully someones raft isnt greater than 1000 pieces in a direction
    local x = v.x + 1000
    local y = v.y + 1000
    local z = v.z + 1000

    return x + 1000 * ( y + 1000 * z )
end

local lastid = 0
RVR.raftLookup = RVR.raftLookup or {}

function RVR.newRaft( id )
    lastid = lastid + 1

    local raft = {
        pieces = {},
        owners = {},
        grid = {},
        id = id or lastid
    }

    setmetatable( raft, raftMeta )

    RVR.raftLookup[raft.id] = raft
    if not SERVER then return raft end

    net.Start( "RVR_Raft_NewRaft" )
        net.WriteInt( raft.id, 32 )
    net.Broadcast()

    return raft
end

function RVR.removeRaft( id )
    local raft = RVR.raftLookup[id]
    RVR.raftLookup[id] = nil

    if not SERVER then return end

    if raft.partyID then
        RVR.Party.removeParty( raft.partyID )
    end

    net.Start( "RVR_Raft_RemoveRaft" )
        net.WriteInt( id, 32 )
    net.Broadcast()

    for _, ent in pairs( raft.pieces ) do
        if ent:IsValid() then
            ent:Remove()
        end
    end
end

function RVR.getRaft( id )
    return RVR.raftLookup[id]
end

if SERVER then
    util.AddNetworkString( "RVR_Raft_NewRaft" )
    util.AddNetworkString( "RVR_Raft_RemoveRaft" )
    util.AddNetworkString( "RVR_Raft_NewRaftPiece" )
    util.AddNetworkString( "RVR_Raft_RequestRaftPieces" )
    util.AddNetworkString( "RVR_Raft_SetPartyID" )

    net.Receive( "RVR_Raft_RequestRaftPieces", function( _, ply )
        for _, raft in pairs( RVR.raftLookup ) do
            net.Start( "RVR_Raft_NewRaft" )
                net.WriteInt( raft.id, 32 )
            net.Send( ply )

            for index, piece in pairs( raft.pieces ) do
                net.Start( "RVR_Raft_NewRaftPiece" )
                    net.WriteInt( raft.id, 32 )
                    net.WriteInt( index, 32 )
                    net.WriteVector( raft:GetPosition( piece ) )
                net.Send( ply )
            end
        end
    end )
end

if CLIENT then
    net.Receive( "RVR_Raft_NewRaft", function()
        local id = net.ReadInt( 32 )
        RVR.newRaft( id )
    end )

    net.Receive( "RVR_Raft_RemoveRaft", function()
        local id = net.ReadInt( 32 )
        RVR.removeRaft( id )
    end )

    net.Receive( "RVR_Raft_NewRaftPiece", function()
        local raftid = net.ReadInt( 32 )
        local entindex = net.ReadInt( 32 )
        local position = net.ReadVector()
        timer.Simple( 0.1, function() -- entity is not created when net message arrives
            local ent = Entity( entindex )
            local raft = RVR.getRaft( raftid )

            if not IsValid( ent ) then return end

            raft.pieces[entindex] = ent
            raft.grid[raft.vectorIndex( position )] = ent
        end )
    end )

    net.Receive( "RVR_Raft_SetPartyID", function()
        local raftID = net.ReadInt( 32 )
        local partyID = net.ReadInt( 32 )

        local raft = RVR.getRaft( raftID )
        if not raft then return end

        raft:SetPartyID( partyID )
    end )

    hook.Add( "InitPostEntity", "RVR_RequestRaftPieces", function()
        net.Start( "RVR_Raft_RequestRaftPieces" )
        net.SendToServer()
    end )
end
