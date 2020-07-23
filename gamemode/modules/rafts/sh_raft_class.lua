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

function raftMeta:RemovePiece( ent )
    self.pieces[ent:EntIndex()] = nil
end

function raftMeta:Remove()
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

-- Attempts to find a spawnable part that can fit a player on, else spawns significantly above the highest part
function raftMeta:GetSpawnPosition( ply )
    local config = GAMEMODE.Config.Rafts

    local mins, maxs = ply:GetCollisionBounds()
    local _, highestPiece = next( self.pieces )

    for _, raftPiece in pairs( self.pieces ) do
        if not IsValid( raftPiece ) then continue end

        if config.SPAWNPOINT_PARTS[raftPiece:GetClass()] then
            local size = raftPiece:OBBMaxs() - raftPiece:OBBMins()
            local center = raftPiece:OBBCenter()
            local top = raftPiece:GetPos() + center + Vector( 0, 0, size.z * 0.5 + 1 )

            local traceResult = util.TraceHull {
                start = top,
                endpos = top,
                filter = ply,
                mins = mins,
                maxs = maxs,
                mask = MASK_PLAYERSOLID
            }

            if not traceResult.Hit then
                return top
            end
        end

        if raftPiece:GetPos().z > highestPiece:GetPos().z then
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
end

function raftMeta:CanBuild( ply )
    if ply:IsSuperAdmin() then return true end

    return ply:GetPartyID() == self.partyID
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

    net.Start( "RVR_Raft_RemoveRaft" )
        net.WriteInt( id, 32 )
    net.Broadcast()

    for _, ent in pairs( raft.pieces ) do
        if ent:IsValid() then
            ent:Remove()
        end
    end
end


if SERVER then
    util.AddNetworkString( "RVR_Raft_NewRaft" )
    util.AddNetworkString( "RVR_Raft_RemoveRaft" )
    util.AddNetworkString( "RVR_Raft_NewRaftPiece" )
    util.AddNetworkString( "RVR_Raft_RequestRaftPieces" )

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
            local raft = RVR.raftLookup[raftid]

            if not IsValid( ent ) then return end

            raft.pieces[entindex] = ent
            raft.grid[raft.vectorIndex( position )] = ent
        end )
    end )

    hook.Add( "InitPostEntity", "RVR_RequestRaftPieces", function()
        net.Start( "RVR_Raft_RequestRaftPieces" )
        net.SendToServer()
    end )
end
