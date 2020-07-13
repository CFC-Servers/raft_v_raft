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

        local mat = RVR.Util.getModelTexture( cls.Model, cls.PreviewPos, cls.PreviewAngle )
        self.radial:AddItem( cls.PrintName, mat, function()
            self:SetSelectedClass( clsName )
        end )
    end
    
    local raftBuilder = self
    function self.radial:customPaint()
        draw.NoTexture()
        if not raftBuilder.selectedClassTable then return end
        local required = raftBuilder.selectedClassTable.GetRequiredItems()
        for i, itemData in ipairs( required ) do
            raftBuilder.drawItemRequirement( ScrW() / 2, ScrH() *0.48 + i * 40, itemData.item.type, itemData.count, "DermaLarge" )
        end 
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
    if not ent or not ent.IsRaft then return self.ghost:SetColor( GHOST_INVIS ) end

    if self.selectedClassTable.IsRaft then
        return self:PiecePreview()
    end

    if self.selectedClassTable.IsWall then
        return self:WallPreview()
    end
end

function SWEP:WallPreview()
    local ent = self:GetAimEntity()
    local pos = ent:GetWallOrigin()

    self.ghost:SetColor( GHOST_COLOR )

    self.ghost:SetModel( self.selectedClassTable.Model )
    self.ghost:SetColor( GHOST_COLOR )

    self.ghost:SetPos( ent:LocalToWorld( pos ) )
    self.ghost:SetAngles( ent:LocalToWorldAngles( Angle( 0, self.yaw, 0 ) ) )
end

function SWEP:PiecePreview()
    local ent = self:GetAimEntity()

    local localDir = self:GetPlacementDirection()

    if not localDir then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local raft = ent:GetRaft()
    if not raft then return end

    local dir = ent:ToRaftDir( localDir )

    local targetPosition = raft:GetPosition( ent ) + dir

    if not self.selectedClassTable.IsWall and raft:GetPiece( targetPosition ) then return end

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


    if self.selectedClassTable.IsWall then
        RunConsoleCommand( "rvr", "place_wall", ent:EntIndex(), self.selectedClass, self.yaw )
    end

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

    self.yaw = ( self.yaw + 90 ) % 360
end

local itemCountCache = {}
local itemMaterialCache = {}
local iconSizeMult = 1.1

hook.Add( "RVR_InventoryCacheUpdate", "RVR_ItemCountCacheClear", function()
    itemCountCache = {}
end )

function SWEP.drawItemRequirement( x, y, itemType, requirement, font )
    local count
    if itemCountCache[itemType] then
        count = itemCountCache[itemType]
    else
        count = RVR.Inventory.selfGetItemCount( itemType )

        itemCountCache[itemType] = count
    end

    local icon
    if itemMaterialCache[itemType] then
        icon = itemMaterialCache[itemType]
    else
        local itemData = RVR.Items.getItemData( itemType )
        icon = Material( itemData.icon )

        itemMaterialCache[itemType] = icon
    end

    local text = count .. "/" .. requirement

    surface.SetFont( font )
    local textW, textH = surface.GetTextSize( text )

    local iconSize = textH * iconSizeMult

    local w, h = textW + iconSize + 5, textH

    surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( icon )
    surface.DrawTexturedRect( x - w * 0.5, y - iconSize * 0.5, iconSize, iconSize )

    if count >= requirement then
        surface.SetTextColor( 0, 255, 0 )
    else
        surface.SetTextColor( 255, 0, 0 )
    end

    surface.SetTextPos( x - w * 0.5 + iconSize + 5, y - textH * 0.5 )
    surface.DrawText( text )
end
