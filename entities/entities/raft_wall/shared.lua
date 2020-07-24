ENT.Base = "raft_breakable_base"
ENT.Author = "THE Gaft Gals ;)"
ENT.PrintName = "Wall"
ENT.Model = "models/rvr/raft/wall.mdl"
ENT.IsWall = true
ENT.PreviewPos = Vector( 100, 0, -5 )
ENT.PreviewAngle = Angle( -30, 45, -30 )

function ENT:SetRaft( raft )
    self:SetRaftID( raft.id )
end

function ENT:GetRaft( raft )
    return RVR.raftLookup[self:GetRaftID()]
end

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

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "RaftID" )

    if SERVER then
        self:SetRaftID( 0 )
    end
end
