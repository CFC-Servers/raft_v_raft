local function getFirstNonZero( tbl )
    for k, v in pairs( tbl ) do
        if math.Round( v ) ~= 0 then 
            print(k,v,math.floor(v))
            return k, v 
        end   
    end
end

function RVR.getSizeFromDirection( ent, dir )
    local size = ent:OBBMaxs() - ent:OBBMins()
    local vec = size * dir
    print(vec)
    local _, size = getFirstNonZero( {vec.x, vec.y, vec.z} )
    return math.abs( size )
end
