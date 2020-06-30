include("shared.lua") 

local abs = math.abs

local GHOST_COLOR = Color( 0, 255, 0, 150 )
local GHOST_INVIS = Color( 0, 0, 0, 0 )

function SWEP:Initialize()
    self.ghost = ClientsideModel( "models/rvr/raft/raft_base.mdl", RENDERGROUP_BOTH )
    self:SetSelectedClass( "raft_platform" )
    self.ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
    self.ghost:SetColor( Color( 0, 0, 0, 0 ) )

    self.yaw = 0
    
end

function SWEP:SetSelectedClass( cls )
    self.selectedClass = cls
    self.selectedClassTable = baseclass.Get( self.class )
    self.ghost:SetModel( self.selectedClassTable.Model )
end

function SWEP:OnRemove()
    self.ghost:Remove()
end

function SWEP:Think() 
    local ent = self:GetAimEntity()
    if not ent or not ent.IsRaft then 
        return self.ghost:SetColor( GHOST_INVIS ) 
    end

    local dir = self:GetPlacementDirection()
    if not dir then 
        return self.ghost:SetColor( GHOST_INVIS ) 
    end

    self.ghost:SetColor( GHOST_COLOR )

    local size = RVR.getSizeFromDirection( ent, dir )

    self.ghost:SetModel( ent:GetModel() )
    self.ghost:SetColor( GHOST_COLOR )
 
    self.ghost:SetPos( ent:LocalToWorld( dir * size ) )
    self.ghost:SetAngles( ent:GetAngles() + Angle( 0, self.yaw, 0 ) )
end

function SWEP:GetAimEntity()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid( ent ) then return nil end

    return ent
end

function SWEP:GetPlacementDirection()
    local ent = self:GetAimEntity()

    if not ent then return end
    if not ent.IsRaft then return end

    if ent:GetClass() == "raft_platform" or ent:GetClass() == "raft_stairs" then
        return Vector( 0, 0, 1 )
    end

    local ply = self:GetOwner()

    local pos = ply:GetAimVector() + ent:GetPos()
    local dir = ent:WorldToLocal( pos )
  
    dir.x = math.Round( dir.x )
    dir.y = math.Round( dir.y )
    dir.z = math.Round( dir.z ) 
    local sum = abs(dir.x) + abs(dir.y) + abs(dir.z)

    if sum ~= 1 then return end

    return dir
end

function SWEP:PrimaryAttack()
    local ent = self:GetAimEntity()
    if not ent or not ent.IsRaft then return end

    local dir = self:GetPlacementDirection()
    if not dir then  return end

    
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
    self.yaw = ( self.yaw + 90 ) % 360
end
