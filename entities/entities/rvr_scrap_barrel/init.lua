AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

local indexCounter = 0

function ENT:Initialize()
    self:SetModel( self.Model )

    -- Set up despawn timer
    local despawnTime = GAMEMODE.Config.Trash.BARREL_DESPAWN_TIME
    if despawnTime > 0 then
        self.timerIdentifier = "rvr_scrap_barrel_despawn_" .. indexCounter
        indexCounter = indexCounter + 1
        local this = self

        timer.Create( this.timerIdentifier, despawnTime, 1, function()
            if IsValid( this ) then
                this.despawning = true
                this:Remove()
            end
        end )
    end

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType( SIMPLE_USE )
    self:SetCollisionGroup( COLLISION_GROUP_WEAPON )

    local physObj = self:GetPhysicsObject()

    if physObj:IsValid() then
        physObj:Wake()
        physObj:EnableMotion( true )
        physObj:SetBuoyancyRatio( 0.2 )
    end
end

function ENT:OnRemove()
    if self.timerIdentifier then
        timer.Remove( self.timerIdentifier )
    end

    if self.despawning then return end

    for i, itemData in pairs( self.items ) do
        local itemInstance = RVR.Items.getItemInstance( itemData.itemType )

        local droppedItem = ents.Create( "rvr_dropped_item" )
        droppedItem:Setup( itemInstance, itemData.count )
        droppedItem:SetPos( self:GetPos() + Vector( math.Rand( -5, 5 ), math.Rand( -5, 5 ), math.Rand( -5, 5 ) ) )
        droppedItem:Spawn()
    end
end

function ENT:OnTakeDamage()
    self:Remove()
end

function ENT:SetItems( items )
    self.items = items
end
