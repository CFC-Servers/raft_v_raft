local PANEL = {}

local background = Material( "rvr/backgrounds/item_tooltip_background.png" )

local h = ScrH() * 0.12
local w = h * ( background:Width() / background:Height() ) * 1.6

local yellow = Color( 188, 162, 105 )

local spillover = 6

surface.CreateFont( "RVR_TooltipDesc", {
    font = "Tahoma",
    size = ScrH() * 0.02,
    weight = 500
} )

function PANEL:Init()
    self:SetSize( w, h )

    self.foreground = vgui.Create( "DImage", self )
    self.foreground:SetImage( "rvr/backgrounds/item_tooltip_foreground.png" )
    self.foreground:Dock( FILL )
    self.foreground:DockMargin( 3, 3, 3, 3 )

    self.itemBackground = vgui.Create( "DImage", self.foreground )
    self.itemBackground:SetImage( "rvr/backgrounds/dark_slot_background.png" )
    self.itemBackground:Dock( LEFT )

    function self.itemBackground:PerformLayout()
        self:SetWide( self:GetTall() )
    end

    self.itemIcon = vgui.Create( "DImage", self.itemBackground )
    self.itemIcon:Dock( FILL )
    self.itemIcon:DockMargin( 14, 14, 14, 14 )

    self.itemName = vgui.Create( "DLabel", self.foreground )
    self.itemName:SetText( "" )
    self.itemName:SetTextColor( yellow )
    self.itemName:SetFont( "RVR_CraftingLabel" )
    self.itemName:Dock( TOP )
    self.itemName:DockMargin( 10, 14, 14, 14 )

    self.underline = vgui.Create( "DShape", self.foreground )
    self.underline:SetType( "Rect" )
    self.underline:SetColor( yellow )

    local this = self

    function self.underline:PerformLayout()
        local _w, _h = this.foreground:GetSize()
        local iconW = this.itemBackground:GetWide()
        self:SetPos( iconW + 5, _h * 0.36 )
        self:SetSize( _w - iconW - 10, 3 )
    end

    self.itemDescription = vgui.Create( "DLabel", self.foreground )
    self.itemDescription:SetText( "" )
    self.itemDescription:SetWrap( true )
    self.itemDescription:SetTextColor( yellow )
    self.itemDescription:SetFont( "RVR_TooltipDesc" )
    self.itemDescription:SetAutoStretchVertical( true )

    function self.itemDescription:PerformLayout()
        local _w, _h = this.foreground:GetSize()
        local iconW = this.itemBackground:GetWide()
        self:SetPos( iconW + 10, _h * 0.4 )
        self:SetWide( _w - iconW - 20 )
    end

    self.iconContainer = vgui.Create( "DPanel", self.foreground )
    self.iconContainer.Paint = nil

    function self.iconContainer:PerformLayout()
        local _w, _h = this.foreground:GetSize()
        self:SetPos( _w * 0.7 - 5, 2 )
        self:SetSize( _w * 0.3, _h * 0.36 - 4 )
    end
end

function PANEL:AddIcon( name )
    local icon = vgui.Create( "DImage", self.iconContainer )
    icon:Dock( RIGHT )
    icon:SetImage( "rvr/icons/item_property_" .. name .. ".png" )

    function icon:PerformLayout()
        self:SetWide( self:GetTall() )
    end
end

function PANEL:ClearIcons()
    self.iconContainer:Clear()
end

function PANEL:Paint( _w, _h )
    DisableClipping( true )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.SetMaterial( background )
    surface.DrawTexturedRect( -spillover, -spillover, _w + ( spillover * 2 ), _h + ( spillover * 2 ) )

    DisableClipping( false )
end

local function updateIsMaterial( item )
    if item.isMaterialSet then return end

    for _, category in pairs( GAMEMODE.Config.Crafting.RECIPES ) do
        for _, recipe in pairs( category.recipes ) do
            if recipe.ingredients[item.type] then
                item.isMaterialSet = true
                item.isMaterial = true
                return
            end
        end
    end

    item.isMaterial = false
    item.isMaterialSet = true
end

function PANEL:SetItem( item )
    self.itemIcon:SetImage( item.icon )
    self.itemName:SetText( item.displayName )
    self.itemDescription:SetText( item.description )

    self:ClearIcons()
    updateIsMaterial( item )
    
    if item.isMaterial then
        self:AddIcon( "craftable" )
    end

    if item.consumable then
        self:AddIcon( "edible" )
    end

    if item.swep then
        self:AddIcon( "tool" )
    end
end

vgui.Register( "RVR_ItemTooltip", PANEL )
