include( "shared.lua" )


local GHOST_COLOR = Color( 0, 255, 0, 150 )
local GHOST_INVIS = Color( 0, 0, 0, 0 )

local ghost = ClientsideModel( "models/rvr/raft/raft_base.mdl", RENDERGROUP_BOTH )
ghost:SetRenderMode( RENDERMODE_TRANSCOLOR )
ghost:SetColor( GHOST_INVIS )

function SWEP:GetItemModel()
    return self.itemData and self.WorldModel or ""
end

function SWEP:GetViewModelOffset()
    local offset = Vector( 5, 10, -5 )

    if self.itemData and self.itemData.viewModelOffset then
        offset = offset + self.itemData.viewModelOffset
    end

    return offset
end

function SWEP:GetViewModelAng()
    local ang = Angle( 15, 0, 0 )

    if self.itemData and self.itemData.viewModelAng then
        ang = ang + self.itemData.viewModelAng
    end

    return ang
end

function SWEP:GetWorldModelOffset()
    local offset = Vector( 5, -2.7, -3.4 )

    if self.itemData and self.itemData.worldModelOffset then
        offset = offset + self.itemData.worldModelOffset
    end

    return offset
end

function SWEP:GetWorldModelAng()
    local ang = Angle( 180, 90, 0 )

    if self.itemData and self.itemData.worldModelAng then
        ang = ang + self.itemData.worldModelAng
    end

    return ang
end

function SWEP:ShouldDrawViewModel()
    return self:GetItemModel() ~= ""
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
    -- Update view model when needed
    local mdl = self:GetItemModel()

    if mdl ~= "" and mdl ~= vm:GetModel() then
        vm:SetWeaponModel( mdl, self )

        vm:SetMaterial( self.itemData.material or "" )
        vm:SetColor( self.itemData.color or Color( 255, 255, 255 ) )
    end
end

-- Position view model based on ViewModelAng and ViewModelOffset
function SWEP:GetViewModelPosition( eyePos, eyeAng )
    local viewModelAng = self:GetViewModelAng()
    local viewModelOffset = self:GetViewModelOffset()

    if self.consumeAnimStart then
        local timePassed = SysTime() - self.consumeAnimStart
        local progress = timePassed / self.Cooldown

        -- 0 -> 0.25 -> 0.5 -> 0.75 -> 1
        progress = math.Clamp( progress, 0, 1 )

        -- 0 -> 0.25 -> 0.5 -> 0.25 -> 0
        local pingPonged = 0.5 - math.abs( 0.5 - progress )
        -- 0 -> 1 -> 1 -> 1 -> 0
        local clamped = math.Clamp( pingPonged * 4, 0, 1 )

        -- moves -0.5 -> 0.5 in sine wave while clamped is 1, giving the "munching" effect
        local munch = 0

        if clamped == 1 then
            local munchProg = ( 0.25 - pingPonged ) / 0.75
            munch = math.sin( munchProg * math.pi * 8 ) * 0.5
        end

        viewModelOffset = viewModelOffset + Vector( 0, clamped * -10, munch )
        viewModelAng = viewModelAng + Angle( 0, clamped * 10, 0 )
    end

    eyeAng:RotateAroundAxis( eyeAng:Right(), viewModelAng.x )
    eyeAng:RotateAroundAxis( eyeAng:Up(), viewModelAng.y )
    eyeAng:RotateAroundAxis( eyeAng:Forward(), viewModelAng.z )

    eyePos = eyePos + viewModelOffset.x * eyeAng:Right()
    eyePos = eyePos + viewModelOffset.y * eyeAng:Forward()
    eyePos = eyePos + viewModelOffset.z * eyeAng:Up()

    return eyePos, eyeAng
end

-- Delete client side model (required)
function SWEP:OnRemove()
    if IsValid( self.WorldModelEnt ) then
        self.WorldModelEnt:Remove()
    end
    ghost:SetColor( GHOST_INVIS )
end

-- Taken from wiki, might not all be needed, but idk
function SWEP:DrawWorldModel()
    if not IsValid( self.WorldModelEnt ) then return end
    local owner = self:GetOwner()

    if IsValid( owner ) then
        local offsetVec = self:GetWorldModelOffset()
        local offsetAng = self:GetWorldModelAng()

        local boneid = owner:LookupBone( "ValveBiped.Bip01_R_Hand" ) -- Right Hand
        if not boneid then return end

        local matrix = owner:GetBoneMatrix( boneid )
        if not matrix then return end

        local newPos, newAng = LocalToWorld( offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles() )

        self.WorldModelEnt:SetPos( newPos )
        self.WorldModelEnt:SetAngles( newAng )

        self.WorldModelEnt:SetupBones()
    else
        self.WorldModelEnt:SetPos( self:GetPos() )
        self.WorldModelEnt:SetAngles( self:GetAngles() )
    end

    self.WorldModelEnt:DrawModel()
end

function SWEP:Think()
    local _, item, pos, ang = self:GetPlacementInfo()
    if not item then return ghost:SetColor( GHOST_INVIS ) end
    local class = baseclass.Get( item.placeableClass )

    ghost:SetColor( GHOST_COLOR )
    ghost:SetModel( class.Model )
    ghost:SetPos( pos )
    ghost:SetAngles( ang )
end
