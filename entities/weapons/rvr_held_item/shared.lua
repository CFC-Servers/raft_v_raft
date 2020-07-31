SWEP.PrintName = "<held_item>"
SWEP.Author = "CFC Dev Team"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "None"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"

SWEP.BobScale = 0.1
SWEP.SwayScale = 0
SWEP.DrawAmmo = false
SWEP.Cooldown = 1

function SWEP:SetupDataTables()
    self:NetworkVar( "String", 1, "ItemType" )
end

function SWEP:Initialize()
    self:SetWeaponHoldType( "melee" )

    if not CLIENT then return end

    -- Set up network var listener to update client data
    self:NetworkVarNotify( "ItemType", function( this, _, _, itemType )
        local itemData = RVR.Items.getItemData( itemType )
        if not itemData then return end

        this.itemData = itemData

        local mdl = this.itemData.model
        if not mdl then
            local wep = weapons.Get( this.itemData.swep )
            if not wep then return end

            mdl = wep.WorldModel
        end

        this.WorldModel = mdl

        if not IsValid( self.WorldModelEnt ) then
            self.WorldModelEnt = ClientsideModel( self.WorldModel )

            if self.WorldModelEnt then
                self.WorldModelEnt:SetNoDraw( true )
            end
        else
            self.WorldModelEnt:SetModel( mdl )
        end

        if self.WorldModelEnt then
            if itemData.material then
                self.WorldModelEnt:SetMaterial( itemData.material )
            end

            if itemData.color then
                self.WorldModelEnt:SetColor( itemData.color )
            end
        end
    end )
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire( CurTime() + self.Cooldown )

    if CLIENT then
        if CurTime() < ( self.nextFire or 0 ) then return end
        self.nextFire = CurTime() + self.Cooldown
    end

    local itemType = self:GetItemType()
    if not itemType then return end

    local itemData = RVR.Items.getItemData( itemType )
    local owner = self:GetOwner()
    if not itemData then return end

    if SERVER and itemData.placeable then
        self.itemData = itemData
        local parentPiece, item, pos, ang = self:GetPlacementInfo()

        if item then RVR.Builder.tryPlaceItem( owner, parentPiece, item, pos, ang ) end
    end

    if not itemData.consumable then return end
    if not itemData:canConsume( owner ) then return end


    local hookID = "RVR_HeldItemConsume" .. owner:EntIndex()

    hook.Add( "RVR_Inventory_CanChangeHotbarSelected", hookID, function( ply, idx )
        if ply ~= owner then return end
        return false
    end )

    timer.Simple( self.Cooldown, function()
        hook.Remove( "RVR_Inventory_CanChangeHotbarSelected", hookID )
    end )

    if SERVER then
        timer.Simple( self.Cooldown, function()
            local inv = owner.RVR_Inventory
            RVR.Inventory.consumeInSlot( owner, inv.HotbarSelected, 1 )

            hook.Remove( "RVR_PreventInventory", hookID )
            hook.Remove( "RVR_PreventCraftingMenu", hookID )
            hook.Remove( "RVR_PreventDropItem", hookID )
        end )

        timer.Simple( self.Cooldown * 0.5, function()
            itemData:onConsume( owner )
        end )

        hook.Add( "RVR_PreventInventory", hookID, function( ply, idx )
            if ply ~= owner then return end
            return true
        end )

        hook.Add( "RVR_PreventCraftingMenu", hookID, function( ply, idx )
            if ply ~= owner then return end
            return true
        end )

        hook.Add( "RVR_PreventDropItem", hookID, function( ply, itemData )
            if ply ~= owner then return end
            return true
        end )
    else
        self.consumeAnimStart = SysTime()

        timer.Simple( self.Cooldown, function()
            self.consumeAnimStart = nil
        end )
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:GetPlacementInfo()
    local trace = self:GetOwner():GetEyeTrace()
    if not self.itemData then return end
    if not self.itemData.placeable then return end
    if not trace.Hit then return end

    local class = baseclass.Get( self.itemData.placeableClass )
    if not class then return end
    if not IsValid( trace.Entity ) then return end
    if not trace.Entity.IsRaft then return end

    local offset = class.PlacementOffset or Vector( 0, 0, 0 )
    local pos = trace.HitPos + offset
    if not class.Model then return end

    local mins, maxs = RVR.Util.GetModelBounds( class.Model )

    local traceData = {
        start = pos,
        endpos = pos,
        filter = ghost,
        mins = mins + Vector( 5, 5, 5 ),
        maxs = maxs - Vector( 5, 5, 5 ),
        mask = MASK_ALL,
        ignoreworld = true
    }

    local traceResult = util.TraceHull( traceData )
    if traceResult.Hit then return end

    local ang = self:GetOwner():EyeAngles()
    ang.pitch = 0
    ang.roll = 0

    return trace.Entity, self.itemData, pos, ang
end
