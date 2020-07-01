RVR.Crafting = RVR.Crafting or {}

util.AddNetworkString( "RVR_Crafting_AttemptCraft" )

net.Receive( "RVR_Crafting_AttemptCraft", function( len, ply )
    local categoryID = net.ReadInt( 8 )
    local recipeID = net.ReadInt( 8 )

    local category = RVR.Crafting.Recipes[categoryID]
    if not category then return end

    local recipe = category.recipes[recipeID]
    if not recipe then return end

    local itemInstance = RVR.Items.getInstance( recipe.item )
    local canFit = RVR.Inventory.canFitItem( ply.RVR_Inventory, itemInstance, recipe.count or 1 )

    if not canFit then return end

    
end )
