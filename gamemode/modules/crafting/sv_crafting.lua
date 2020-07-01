RVR.Crafting = RVR.Crafting or {}
local cft = RVR.Crafting

util.AddNetworkString( "RVR_Crafting_AttemptCraft" )
util.AddNetworkString( "RVR_Crafting_CraftResponse" )
util.AddNetworkString( "RVR_Crafting_CloseCraftingMenu" )
util.AddNetworkString( "RVR_Crafting_OpenCraftingMenu" )
util.AddNetworkString( "RVR_Crafting_Grab" )

local function craftFail( ply )
    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteBool( false )
    net.Send( ply )
end

net.Receive( "RVR_Crafting_Grab", function( len, ply )
    local ent = net.ReadEntity()

    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteBool( false )
    net.Send( ply )
end )

net.Receive( "RVR_Crafting_AttemptCraft", function( len, ply )
    local categoryID = net.ReadInt( 8 )
    local recipeID = net.ReadInt( 8 )

    local category = RVR.Crafting.Recipes[categoryID]
    if not category then return craftFail( ply ) end

    local recipe = category.recipes[recipeID]
    if not recipe then return craftFail( ply ) end

    if not cft.craft( ply, recipe ) then craftFail( ply ) end
end )

function cft.craft( ply, recipe )
    local craftingEnt = ply.RVR_CraftingEnt or ply
    local tier = craftingEnt.RVR_CraftingTier or 1
    if tier < recipe.tier then return end

    local itemInstance = RVR.Items.getItemInstance( recipe.item )
    local canFit = RVR.Inventory.canFitItem( ply.RVR_Inventory, itemInstance, recipe.count or 1 )

    if not canFit then return end

    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteBool( true )
    net.Send( ply )

    return true
end

function cft.openMenu( ply, ent )
    net.Start( "RVR_Crafting_OpenCraftingMenu" )
    net.WriteEntity( ent )
    net.Send( ply )

    ply.RVR_CraftingEnt = ent
end

net.Receive( "RVR_Crafting_CloseCraftingMenu", function( len, ply )
    ply.RVR_CraftingEnt = nil
end )
