local raftMeta = {}
raftMeta.__index = raftMeta

function raftMeta:AddPiece( position, ent )
    ent.RaftGridPosition = position
    self.pieces[ent:EntIndex()] = ent
    self.grid[self.vectorIndex( position )] = ent:EntIndex()
end

function raftMeta:RemovePiece( ent )
    self.pieces[ent:EntIndex()] = nil
end

function raftMeta:GetPieceInGrid( position )
    local index = self.grid[self.vectorIndex( position )]
    if not index then return end
    return self.pieces[index]
end

-- ownership
function raftMeta:AddOwner( ply )
    self.owners[ply:SteamID()] = true
end

function raftMeta:RemoveOwnerID( steamid )
    self.owners[steamid] = nil
end

function raftMeta:IsOwner( ply )
    return self.owners[ply:SteamID()] == true
end

-- util
function raftMeta.vectorIndex( v )
    -- hopefully someones raft isnt greater than 1000 pieces in a direction
    local x = v.x + 1000
    local y = v.y + 1000
    local z = v.z + 1000
    return x + 1000 * ( y + 1000 * z)
end

function RVR.newRaft( piece )
    local r = {
        pieces = {},
        owners = {},
        grid   = {},
    }

    setmetatable( r, raftMeta )
    return r
end
