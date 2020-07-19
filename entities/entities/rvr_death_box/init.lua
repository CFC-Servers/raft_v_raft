AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self.BaseClass.Initialize( self )

    -- Set up despawn timer
    local despawnTime = GAMEMODE.Config.PlayerDeath.DEATH_BOX_DESPAWN_TIME
    if despawnTime > 0 then
        self.timerIdentifier = "rvr_death_box_despawn_" .. self:EntIndex()
        local this = self

        timer.Create( this.timerIdentifier, despawnTime, 1, function()
            if IsValid( this ) then this:Remove() end
        end )
    end

    local depth = ( RVR.waterSurfaceZ or 0 ) - self:GetPos().z

    if depth > GAMEMODE.Config.PlayerDeath.DEATH_BOX_ANCHOR_DEPTH then
        local trace = util.TraceLine( {
            start = self:GetPos(),
            endpos = self:GetPos() - Vector( 0, 0, 100000000 ),
            mask = MASK_NPCWORLDSTATIC,
        } )

        if not trace.Hit then return end
        constraint.Rope( self, game.GetWorld(), 0, 0, Vector( 0, 0, 0 ),
            trace.HitPos, trace.HitPos:Distance( self:GetPos() ), 0, 0, 2, "cable/rope" )
    end
end

function ENT:Think()
    local phys = self:GetPhysicsObject()

    local entAng = phys:GetAngles()
    local forward = Vector( 1, 0, 0 ):Angle()

    local p = math.rad( math.AngleDifference( entAng.p, forward.p ) )
    local y = 0
    local r = math.rad( math.AngleDifference( entAng.r, forward.r ) )

    local damp = 0.75
    local strength = 100
    local divAng = Vector( p, y, 0 )
    divAng:Rotate( Angle( 0, -entAng.r, 0 ) )

    phys:AddAngleVelocity( ( -Vector( r, divAng.x, divAng.y ) * strength ) - ( phys:GetAngleVelocity() * damp ) )
end

function ENT:OnRemove()
    if self.timerIdentifier then
        timer.Remove( self.timerIdentifier )
    end
end

function ENT:TakeFromPlayer( ply )
    if not ply.RVR_Inventory then return end

    self.RVR_Inventory.MaxSlots = 100

    local cursorData = RVR.Inventory.getSlot( ply, -1 )
    if cursorData then
        RVR.Inventory.attemptPickupItem( self, cursorData.item, cursorData.count )
    end

    for k = 1, ply.RVR_Inventory.MaxSlots + 3 do
        local slotData = RVR.Inventory.getSlot( ply, k )
        if slotData then
            RVR.Inventory.attemptPickupItem( self, slotData.item, slotData.count )
        end
    end

    self.RVR_Inventory.MaxSlots = #self.RVR_Inventory.Inventory
    self.RVR_Inventory.PreventAdding = true

    RVR.Inventory.clearInventory( ply )
end
