local raftMeta = {}
raftMeta.__index = raftMeta

function raftMeta:AddPiece( position, ent )
    ent._raftGridPosition = position
    self.pieces[ent:EntIndex()] = ent
    self.grid[self.vectorIndex( position )] = ent:EntIndex()
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
    return piece._raftGridPosition
end

-- ownership
function raftMeta:AddOwnerID( steamid )
    self.owners[steamid] = true
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

function raftMeta:CanBuild( ply )
    print(ply)
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
