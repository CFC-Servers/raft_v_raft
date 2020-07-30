AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup( COLLISION_GROUP_WORLD )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:EnableMotion( true )
    end
end

function ENT:GetPlayerStatus()
    local shouldDie = true
    for _, ply in pairs( player.GetAll() ) do
        local dist = self:GetPos():DistToSqr( ply:GetPos() )
        local spawnRadius = GAMEMODE.Config.Fish.DESPAWN_RADIUS
        local scaredDistance GAMEMODE.Config.Fish.SCARED_DISTANCE

        if dist <= spawnRadius ^ 2 then
            shouldDie = false
        end

        if dist <= scaredDistance ^ 2 then
            return false, ply
        end
    end

    return shouldDie
end

function ENT:Setup( fishData )
    self.type = fishData.type
    self.dropItem = fishData.item
    self.maxHealth = fishData.health
    self.currentHealth = self.maxHealth
    self.moveDistance = fishData.moveDistance
    self.defaultMoveDistance = fishData.moveDistance
    self.moveChance = fishData.moveChance
    self.nextThink = CurTime() + 3
    self.isMoving = false
    self.predictedPos = self:GetPos()
    self.prevPos = self:GetPos()
    self.destination = self:GetPos()

    self:SetModel( fishData.model )
end

function ENT:Think()
    local shouldDie, enemy = self:GetPlayerStatus()
    if shouldDie then
        self:Remove()
    end
 
    if IsValid( enemy ) and not self.enemy then
        self.enemy = enemy
        self.moveDistance = self.moveDistance * 10
        self.nextThink = CurTime()
        self.isMoving = false
    elseif not IsValid( enemy ) then
        self.enemy = nil
        self.moveDistance = self.defaultMoveDistance
    end

    if self.isMoving then
        local destination = self.destination
        local fishPos = self.predictedPos
        local fishAng = ( destination - self.prevPos ):Angle()
        local dist = fishPos:DistToSqr( destination )

        if dist > 5 then
            local newPos = LerpVector( 0.1, fishPos, destination )

            self:SetAngles( fishAng )
            self.predictedPos = newPos
        else
            self.isMoving = false
        end
    else
        local time = CurTime()
        local shouldMove = true--math.random( 1, 100 ) <= self.moveChance

        if time >= self.nextThink then
            if shouldMove then
                local waterZ = RVR.waterSurfaceZ - GAMEMODE.Config.Fish.WATER_LEVEL_BIAS

                self.destination = self:LocalToWorld( VectorRand( -1, 1 ):GetNormalized() * self.moveDistance )
                self.destination.z = math.Clamp( self.destination.z, -math.huge, waterZ )
                self.predictedPos = self:GetPos()
                self.prevPos = self:GetPos()
                self.isMoving = true
            end

            self.nextThink = time + 3
        end
    end

    local phys = self:GetPhysicsObject()
    local massCenter = self:LocalToWorld( phys:GetMassCenter() )
    local force = ( ( self.predictedPos - massCenter ) * 5 - phys:GetVelocity() ) * phys:GetMass()
    phys:ApplyForceCenter( force )
end

function ENT:DropExplode()
    local itemInstance = RVR.Items.getItemInstance( self.dropItem )

    local droppedItem = ents.Create( "rvr_dropped_item" )
    droppedItem:SetPos( self:GetPos() )
    droppedItem:SetAngles( self:GetAngles() )
    droppedItem:Setup( itemInstance, 1 )
    droppedItem:Spawn()

    self:Remove()
end

function ENT:OnTakeDamage( dmg )
    local damage = dmg:GetDamage()

    self.currentHealth = self.currentHealth - damage

    if self.currentHealth <= 0 then
        self:DropExplode()
    end
end
