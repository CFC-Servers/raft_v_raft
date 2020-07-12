SWEP.PrintName = "<held_item>"
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
            mdl = wep.Model
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

    if not itemData or not itemData.consumable then return end
    if not itemData:canConsume( self.Owner ) then return end

    local owner = self.Owner

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
    else
        self.consumeAnimStart = SysTime()
        timer.Simple( self.Cooldown, function()
            self.consumeAnimStart = nil
        end )
    end
end
