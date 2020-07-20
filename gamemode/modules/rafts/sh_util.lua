local function getFirstNonZero( tbl )
    for k, v in pairs( tbl ) do
        if math.Round( v ) ~= 0 then
            return k, v
        end
    end
end

function RVR.getSizeFromDirection( ent, dir )
    local size = ent:OBBMaxs() - ent:OBBMins()
    local vec = size * dir

    local _, size = getFirstNonZero( { vec.x, vec.y, vec.z } )

    return math.abs( size or 0 )
end
