include("shared.lua")

local abs = math.abs

local GHOST_COLOR = Color( 0, 255, 0, 150 )
local GHOST_INVIS = Color( 0, 0, 0, 0 )
local INPUT_DELAY = 0.2

function SWEP:Initialize()
    self.ghost = ClientsideModel( "models/rvr/raft/raft_base.mdl", RENDERGROUP_BOTH )
    self:SetSelectedClass( "raft_platform" )
    self.ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
    self.ghost:SetColor( Color( 0, 0, 0, 0 ) )

    self.yaw = 0

    self.radial = RVR.newRadialMenu()
    
    for _, placeable in pairs( self.Placeables ) do 
        local clsName = placeable.class
        local cls = baseclass.Get( clsName )
        
        self.radial:AddItem( cls.PrintName, Material("rvr/icons/food.png"), function()
            self:SetSelectedClass( clsName )
        end )
    end
end

function SWEP:SetSelectedClass( cls )
    self.selectedClass = cls
    self.selectedClassTable = baseclass.Get( self.selectedClass )
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

    local localDir = self:GetPlacementDirection()
    if not localDir then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local raft = ent:GetRaft()
    if not raft then return end

    local dir = ent:ToRaftDir( localDir )

    local targetPosition = raft:GetPosition( ent ) + dir

    if raft:GetPiece( targetPosition ) then return end

    if not self.selectedClassTable.IsValidPlacement( ent, dir ) then return end

    local size = RVR.getSizeFromDirection( ent, localDir )
    if not size then return end

    localDir = self.selectedClassTable.GetOffsetDir( ent, localDir )

    -- update ghost position
    self.ghost:SetColor( GHOST_COLOR )

    self.ghost:SetModel( self.selectedClassTable.Model )
    self.ghost:SetColor( GHOST_COLOR )

    self.ghost:SetPos( ent:LocalToWorld( localDir * size ) )
    self.ghost:SetAngles( ent:GetAngles() - ent:GetRaftRotationOffset() + Angle( 0, self.yaw, 0 ) )
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

    if self.selectedClass == "raft_platform" or self.selectedClass == "raft_stairs" then
        return Vector( 0, 0, 1 )
    end

    local ply = self:GetOwner()

    local pos = ply:GetAimVector() + ent:GetPos()
    local dir = ent:WorldToLocal( pos )
    if self.selectedClass == "raft_foundation" then
        dir.z = 0
    end
    dir.x = math.Round( dir.x )
    dir.y = math.Round( dir.y )
    dir.z = math.Round( dir.z )
    local sum = abs( dir.x ) + abs( dir.y ) + abs( dir.z )

    if sum ~= 1 then return end

    return dir
end

local nextPrimary = 0
function SWEP:PrimaryAttack()
    if CurTime() <= nextPrimary then return end
    nextPrimary = CurTime() + INPUT_DELAY

    local ent = self:GetAimEntity()
    if not ent or not ent.IsRaft then return end

    local localDir = self:GetPlacementDirection()
    if not localDir then return end

    local raft = ent:GetRaft()
    if not raft then return end

    local dir = ent:ToRaftDir( localDir )

    self.ghost:SetColor( GHOST_INVIS )
    RunConsoleCommand( "rvr", "expand_raft", ent:EntIndex(), self.selectedClass, dir.x, dir.y, dir.z, self.yaw )
end

local nextSecondary = 0
function SWEP:SecondaryAttack()
    if CurTime() <= nextSecondary then return end
    nextSecondary = CurTime() + INPUT_DELAY
   
    gui.EnableScreenClicker( true ) 
    timer.Simple(0, function()
        input.SetCursorPos( ScrW() / 2, ScrH() / 2)
    end)

    self.radial:Open()
    hook.Add("KeyRelease", "RVR_Raft_Builder_Release", function( player, key )
        if key == IN_ATTACK2 then
            self.radial:RunSelected()
            self.radial:Close()    
            gui.EnableScreenClicker( false )
        end
    end)
end

local nextReload = 0
function SWEP:Reload()
    if not self.Owner:KeyPressed( IN_RELOAD ) then return end
    if CurTime() <= nextReload then return end
    nextReload = CurTime() + INPUT_DELAY

    self.yaw = self.yaw % 360 + 90
end
