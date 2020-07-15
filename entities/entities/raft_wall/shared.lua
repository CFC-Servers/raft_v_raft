ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Wall"
ENT.Model = "models/rvr/raft/wall.mdl"
ENT.IsWall = true
ENT.PreviewPos = Vector( 100, 0, -5 )
ENT.PreviewAngle = Angle( -30, 45, -30 )

function ENT.GetRequiredItems()
    local requirements = {}

    for itemName, amount in pairs( GM.Config.Rafts.BUILDING_REQUIREMENTS[ENT.ClassName] ) do
        table.insert(
            requirements,
            { item = RVR.items.getItemData( itemName ), count = amount }
        )
    end

    return requirements
end
