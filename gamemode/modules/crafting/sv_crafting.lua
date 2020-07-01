RVR.Crafting = RVR.Crafting or {}
local cft = RVR.Crafting

util.AddNetworkString( "RVR_Crafting_AttemptCraft" )
util.AddNetworkString( "RVR_Crafting_CraftResponse" )
util.AddNetworkString( "RVR_Crafting_CloseCraftingMenu" )
util.AddNetworkString( "RVR_Crafting_OpenCraftingMenu" )

local function craftFail( ply )
    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteBool( false )
    net.Send( ply )
end

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
    if ( ply.RVR_CraftingTier or 1 ) < recipe.tier then return end

    local itemInstance = RVR.Items.getInstance( recipe.item )
    local canFit = RVR.Inventory.canFitItem( ply.RVR_Inventory, itemInstance, recipe.count or 1 )

    if not canFit then return end


end

function cft.openMenu( ply, t )
    net.Start( "RVR_Crafting_OpenCraftingMenu" )
    net.WriteInt( t, 4 )
    net.Send( ply )

    ply.RVR_CraftingTier = t
end

net.Receive( "RVR_Crafting_CloseCraftingMenu", function( len, ply )
    ply.RVR_CraftingTier = nil
end )
