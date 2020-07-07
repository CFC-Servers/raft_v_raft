local raftMeta = {}
raftMeta.__index = raftMeta
RVR.raftsList = {}

--  TODO when a player joins they need an updated list of rafts
function raftMeta:AddPiece( position, ent )
    ent:SetRaftGridPosition( position )
    self.pieces[ent:EntIndex()] = ent
    self.grid[self.vectorIndex( position )] = ent:EntIndex()

    net.Start("new_raft_piece")
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
    local index = self.grid[self.vectorIndex( position )]
    if not index then return end

    local ent = self.pieces[index]

    if not IsValid( ent ) then
        self.pieces[index] = nil
        return
    end
    return ent
end

function raftMeta:GetNeighbors( piece )
    local neighbors = {}

    for x=-1, 1 do
        for y=-1, 1  do
            for z=-1, 1 do
                local pos = self:GetPosition( piece ) + Vector( x, y, z )
                neighbors[#neighbors+1] = self:GetPiece( pos )
            end
        end
    end

    return neighbors
end

function raftMeta:GetPosition( piece )
    return piece:GetRaftGridPosition()
end

-- ownership
function raftMeta:AddOwnerID( steamid )
    self.owners[steamid] = true

    net.Start("new_raft_owner")
        net.WriteInt( self.id, 32 )
        net.WriteString( steamid )
    net.Broadcast()
end

function raftMeta:AddOwner( ply )
    self:AddOwnerID( ply:SteamID() )
end

function raftMeta:RemoveOwnerID( steamid )
    self.owners[steamid] = nil
end

function raftMeta:RemoveOwner( ply )
    self:RemoveOwnerID( ply:SteamID() )
end

function raftMeta:IsOwner( ply )
    return self.owners[ply:SteamID()] == true
end

function raftMeta:GetOwners()
    local owners = {}
    for steamid, isowner in pairs( self.owners ) do
        local ply = player.GetBySteamID( steamid )
        if ply and isowner then
            owners[#owners+1] = ply
        end
    end

    return owners
end

function raftMeta:CanBuild( ply )
    if self:IsOwner( ply ) then return true end
    if ply:IsSuperAdmin() then return true end

    return false
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
RVR.raftLookup = {}

function RVR.newRaft( id )
    lastid = lastid + 1

    local r = {
        pieces = {},
        owners = {},
        grid   = {},
        id     = id or lastid,
    }

    setmetatable( r, raftMeta )

    RVR.raftLookup[r.id] = r
    if not SERVER then return r end

    net.Start( "new_raft" )
        net.WriteInt( r.id, 32 )
    net.Broadcast()

    return r
end


if SERVER then
    util.AddNetworkString( "new_raft_owner" )
    util.AddNetworkString( "new_raft" )
    util.AddNetworkString( "new_raft_piece" )
end

if CLIENT then
    net.Receive("new_raft", function()
        local id = net.ReadInt(32)
        RVR.newRaft(id)
    end)

    net.Receive("new_raft_piece", function()
        local raftid = net.ReadInt( 32 )
        local entindex = net.ReadInt( 32 )
        local position = net.ReadVector()
        timer.Simple( 0.1, function()
            local ent = Entity( entindex )
            local raft = RVR.raftLookup[raftid]

            if not IsValid( ent ) then return end

            raft.pieces[entindex] = ent
            raft.grid[raft.vectorIndex( position )] = entindex
         end)
    end)

    net.Receive( "new_raft_owner", function()
    -- TODO
    end)
end
