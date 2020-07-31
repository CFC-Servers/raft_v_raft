RVR.Util = RVR.Util or {}

local function entCreate( model )
    local ent = ents.Create( "prop_physics" )
    ent:SetModel( model )

    return ent
end

if CLIENT then entCreate = ents.CreateClientProp end

local modelBoundsCache = {}

function RVR.Util.GetModelBounds( model )
    local cached = modelBoundsCache[model]
    if cached then
        return unpack( cached )
    end

    local ent = entCreate( model )

    local min, max = ent:GetModelBounds()
    ent:Remove()

    modelBoundsCache[model] = { min, max }

    return min, max
end
