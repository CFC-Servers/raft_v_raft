ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Wall"
ENT.Model = "models/rvr/raft/wall.mdl"
ENT.IsWall = true

function ENT:GetRequiredItems()
    local requirements = {}

    for itemName, amount in pairs( GAMEMODE.Config.Rafts.BUILDING_REQUIREMENTS[self.ClassName] ) do
        table.insert(
            requirements,
            {
                item = RVR.Items.getItemData( itemName ),
                count = amount
            }
        )
    end

    return requirements
end
