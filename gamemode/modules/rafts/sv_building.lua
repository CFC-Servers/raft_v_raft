local directions = {}
directions = {
    Vector(1, 0, 0),
    Vector(-1, 0, 0),
    Vector(0, 1, 0),
    Vector(0, -1, 0),
    Vector(0, 0, 1),
}

local function getFirstNonZero( tbl )
    for k, v in pairs( tbl ) do
        if v ~= 0 then return k, v end   
    end
end

local function expandRaft(piece, data)
    if not piece.IsRaft then return end
    local size = piece:OBBMaxs() - piece:OBBMins()
    
    _, size = getFirstNonZero( ( size * data.dir ):ToTable() )
    size = math.abs( size )
    
    local newEnt = ents.Create( data.class )
    newEnt:Spawn()
    newEnt:SetAngles( piece:GetAngles() )
    newEnt:SetPos( piece:LocalToWorld( data.dir * size ) )
    newEnt:SetRaft( piece:GetRaft() )
    newEnt:SetParent( piece )
end
RVR.expandRaft = expandRaft
