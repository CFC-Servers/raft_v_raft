include( "shared.lua" )

function SWEP:ShouldDrawViewModel()
    return self:GetItemModel() ~= ""
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
    -- Update view model when needed
    if self:GetItemModel() ~= "" and self:GetItemModel() ~= vm:GetModel() then
        vm:SetModel( self:GetItemModel() )
    end
end

-- Position view model based on ViewModelAng and ViewModelOffset
function SWEP:GetViewModelPosition( eyePos, eyeAng )
    local viewModelAng = self:GetViewModelAng()
    local viewModelOffset = self:GetViewModelOffset()

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
end

-- Taken from wiki, might not all be needed, but idk
function SWEP:DrawWorldModel()
    if not IsValid( self.WorldModelEnt ) then return end
    local owner = self:GetOwner()

    if IsValid( owner ) then
        -- TODO: Pull out into network vars
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
