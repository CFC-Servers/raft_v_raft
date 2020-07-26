RVR.Util = RVR.Util or {}

local Util = RVR.Util

function Util.segmentGrid( grid )
    local labelCounter = 0
    local labels = {}
    local labelAliases = {}

    for y, column in ipairs( grid ) do
        labels[y] = {}
        for x, val in ipairs( column ) do
            local left
            if x > 1 and labels[y][x - 1] then
                left = labels[y][x - 1]
            end

            local top
            if y > 1 and labels[y - 1][x] then
                top = labels[y - 1][x]
            end

            local out
            if not val then
                out = nil
            elseif left and top then
                if left == top then
                    out = left
                else
                    out = left
                    labelAliases[left] = top
                end
            elseif left then
                out = left
            elseif top then
                out = top
            else
                labelCounter = labelCounter + 1
                out = labelCounter
            end

            labels[y][x] = out
        end
    end

    local out = {}
    local outIndexs = {}
    for y, column in pairs( labels ) do
        for x, val in pairs( column ) do
            if labelAliases[val] then
                val = labelAliases[val]
            end

            if outIndexs[val] then
                table.insert( out[outIndexs[val]], { x = x, y = y } )
            else
                table.insert( out, { { x = x, y = y } } )
                outIndexs[val] = #out
            end
        end
    end

    return out
end
