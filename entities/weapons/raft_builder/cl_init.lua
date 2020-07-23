include( "shared.lua" )

local abs = math.abs

local GHOST_VALID = Color( 0, 255, 0, 150 )
local GHOST_INVALID = Color( 255, 0, 0, 150 )
local GHOST_INVIS = Color( 0, 0, 0, 0 )
local INPUT_DELAY = 0.2

surface.CreateFont( "RVR_RaftBuilderIngredients", {
    font = "Bungee Regular",
    size = ScrH() * 0.045,
    weight = 500
} )

local debugMat = "models/debug/debugwhite"

function SWEP:Initialize()
    self.ghost = ClientsideModel( "models/rvr/raft/raft_base.mdl", RENDERGROUP_BOTH )
    self:SetSelectedClass( "raft_platform" )
    self.ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
    self.ghost:SetColor( Color( 0, 0, 0, 0 ) )

    self.yaw = 0

    self.radial = RVR.newRadialMenu()

    for _, placeable in pairs( GAMEMODE.Config.Rafts.PLACEABLES ) do
        local clsName = placeable.class
        local cls = baseclass.Get( clsName )

        local mat = Material( placeable.icon )

        self.radial:AddItem( cls.PrintName, mat, function()
            self:SetSelectedClass( clsName )
        end )
    end

    local raftBuilder = self
    function self.radial:customPaint()
        self:SetCenterOutlineColor()
        if not self.selectedItem then return end
        draw.NoTexture()
        local className = GAMEMODE.Config.Rafts.PLACEABLES[self.selectedItem].class
        local class = baseclass.Get( className )
        local required = class:GetRequiredItems()

        -- Shifted left slightly from center
        local x = ScrW() * 0.497
        local spacing = 30
        local iconHeight = ScrH() * 0.025
        for i, itemData in ipairs( required ) do
            local y = ScrH() * 0.5 + ( i - 1 ) * spacing
            raftBuilder.drawItemRequirement( x, y, itemData.item.type,
                itemData.count, "RVR_RaftBuilderIngredients", iconHeight )
        end
    end
end

function SWEP:DoDrawCrosshair( x, y )
    return self.radial.isOpen
end

function SWEP:SetSelectedClass( cls )
    self.selectedClass = cls
    self.selectedClassTable = baseclass.Get( self.selectedClass )
    self.ghost:SetModel( self.selectedClassTable.Model )
    self.ghost:SetMaterial( debugMat )
end

function SWEP:OnRemove()
    self.ghost:Remove()
end

function SWEP:Think()
    self:UpdateCanMake()
    self:UpdatePermitted()

    self.radial:SetCenterOutlineColor( self.canMake and Color( 0, 255, 0 ) or Color( 255, 0, 0 ) )

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
    self.wallYaw = nil

    local trace = self:GetOwner():GetEyeTrace()
    local ent = trace.Entity

    if not IsValid( ent ) then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local pos = ent:GetWallOrigin()

    local localHitPos = ent:WorldToLocal( trace.HitPos )
    localHitPos.z = 0
    localHitPos:Normalize()

    localHitPos.x = math.Round( localHitPos.x )
    localHitPos.y = math.Round( localHitPos.y )
    if math.abs( localHitPos.x ) == math.abs( localHitPos.y ) then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    self.wallYaw = localHitPos:Angle().yaw

    self.ghost:SetModel( self.selectedClassTable.Model )
    self.ghost:SetMaterial( debugMat )
    self:UpdateGhostColor()

    self.ghost:SetPos( ent:LocalToWorld( pos ) )
    self.ghost:SetAngles( ent:LocalToWorldAngles( Angle( 0, self.wallYaw, 0 ) ) )
end

function SWEP:PiecePreview()
    local ent = self:GetAimEntity()

    local localDir = self:GetPlacementDirection()

    if not localDir then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local raft = ent:GetRaft()
    if not raft then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local dir = ent:ToRaftDir( localDir )

    local targetPosition = raft:GetPosition( ent ) + dir

    if not self.selectedClassTable.IsWall and raft:GetPiece( targetPosition ) then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    if not self.selectedClassTable.IsValidPlacement( ent, dir ) then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    local size = RVR.getSizeFromDirection( ent, localDir )
    if not size then
        return self.ghost:SetColor( GHOST_INVIS )
    end

    localDir = self.selectedClassTable.GetOffsetDir( ent, localDir )

    -- update ghost position
    self.ghost:SetModel( self.selectedClassTable.Model )
    self.ghost:SetMaterial( debugMat )
    self:UpdateGhostColor()
    self.ghost:SetPos( ent:LocalToWorld( localDir * size ) )
    self.ghost:SetAngles( ent:GetAngles() - ent:GetRaftRotationOffset() + Angle( 0, self.yaw, 0 ) )
end

function SWEP:UpdateGhostColor()
    local ghostValid = self.canMake and self.permitted
    self.ghost:SetColor( ghostValid and GHOST_VALID or GHOST_INVALID )
end

function SWEP:GetAimEntity()
    local owner = self:GetOwner()
    local trace = owner:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid( ent ) then return end

    return ent
end

function SWEP:GetPlacementDirection()
    local ent = self:GetAimEntity()
    if not ( ent and ent.IsRaft ) then return end

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
    if not self.canMake then return end

    if CurTime() <= nextPrimary then return end
    nextPrimary = CurTime() + INPUT_DELAY

    local ent = self:GetAimEntity()
    if not ent or not ent.IsRaft then return end

    if self.selectedClassTable.IsWall then
        if self.wallYaw == nil then return end
        return RunConsoleCommand( "rvr", "place_wall", ent:EntIndex(), self.selectedClass, self.wallYaw )
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

    self.radial:Open()
    hook.Add( "KeyRelease", "RVR_Raft_Builder_Release", function( player, key )
        if key == IN_ATTACK2 then
            self.radial:RunSelected()
            self.radial:Close()
            hook.Remove( "KeyRelease", "RVR_Raft_Builder_Release" )
        end
    end )
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

function SWEP:UpdateCanMake()
    if not self.radial.selectedItem then
        self.canMake = false
        return
    end

    local className = GAMEMODE.Config.Rafts.PLACEABLES[self.radial.selectedItem].class
    local class = baseclass.Get( className )
    local required = class:GetRequiredItems()

    local canMake = true

    for _, itemData in pairs( required ) do
        local itemType, requirement = itemData.item.type, itemData.count

        local count
        if itemCountCache[itemType] then
            count = itemCountCache[itemType]
        else
            count = RVR.Inventory.selfGetItemCount( itemType )

            itemCountCache[itemType] = count
        end

        if count < requirement then
            canMake = false
            break
        end
    end

    self.canMake = canMake
end

function SWEP.drawItemRequirement( x, y, itemType, requirement, font, h )
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
    h = h or textH

    local iconSize = h * iconSizeMult

    local w = textW + iconSize + 5

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

    return count >= requirement
end

function SWEP:UpdatePermitted()
    self.permitted = false

    local trace = self:GetOwner():GetEyeTrace()
    local ent = trace.Entity
    local isRaftEnt = IsValid( ent ) and ent.IsRaft
    if isRaftEnt and ent:GetRaft():CanBuild( LocalPlayer() ) then
        self.permitted = true
    end
end
