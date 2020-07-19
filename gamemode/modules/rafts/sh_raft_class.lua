local raftMeta = {}
raftMeta.__index = raftMeta

function raftMeta:AddPiece( position, ent )
    ent:SetRaftGridPosition( position )
    self.pieces[ent:EntIndex()] = ent
    self.grid[self.vectorIndex( position )] = ent

    net.Start( "RVR_Raft_NewRaftPiece" )
        net.WriteInt( self.id, 32 )
        net.WriteInt( ent:EntIndex(), 32 )
        net.WriteVector( position )
    net.Broadcast()

    -- TODO only owners of the raft should get this info
end

function raftMeta:RemovePiece( ent )
    self.pieces[ent:EntIndex()] = nil
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

-- ownership
function raftMeta:GetParty()
    if not self.partyID then return end
    return party.getParty( self.partyID )
end

function raftMeta:SetParty( party )
    self.partyID = party.ID
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

    local r = {
        pieces = {},
        owners = {},
        grid = {},
        id = id or lastid,
    }

    setmetatable( r, raftMeta )

    RVR.raftLookup[r.id] = r
    if not SERVER then return r end

    net.Start( "RVR_Raft_NewRaft" )
        net.WriteInt( r.id, 32 )
    net.Broadcast()

    return r
end


if SERVER then
    util.AddNetworkString( "RVR_Raft_NewRaftOwner" )
    util.AddNetworkString( "RVR_Raft_NewRaft" )
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

    net.Receive( "RVR_Raft_NewRaftPiece", function()
        local raftid = net.ReadInt( 32 )
        local entindex = net.ReadInt( 32 )
        local position = net.ReadVector()
        timer.Simple( 0.1, function()
            local ent = Entity( entindex )
            local raft = RVR.raftLookup[raftid]

            if not IsValid( ent ) then return end

            raft.pieces[entindex] = ent
            raft.grid[raft.vectorIndex( position )] = ent
        end )
    end )

    net.Receive( "RVR_Raft_NewRaftOwner", function()
    -- TODO
    end )

    hook.Add( "InitPostEntity", "RVR_RequestRaftPieces", function()
        net.Start( "RVR_Raft_RequestRaftPieces" )
        net.SendToServer()
    end )
end
