RVR.Crafting = RVR.Crafting or {}
local cft = RVR.Crafting

cft.STATE_WAITING = 0
cft.STATE_CRAFT_REQUEST = 1
cft.STATE_CRAFTING = 2
cft.STATE_CRAFTED = 3
cft.STATE_GRAB_REQUEST = 4

hook.Add( "PreGamemodeLoaded", "RVR_Crafting_AddRecipes", function()
    hook.Run( "RVR_Crafting_AddRecipes" )

    for catID, category in ipairs( GAMEMODE.Config.Crafting.RECIPES ) do
        local minRecipeTier = 1000
        for recipeID, recipe in pairs( category.recipes ) do
            recipe.tier = recipe.tier or 1
            if recipe.tier < minRecipeTier then
                minRecipeTier = recipe.tier
            end

            recipe.categoryID = catID
            recipe.recipeID = recipeID

            recipe.itemsStruct = {}
            for name, count in pairs( recipe.ingredients ) do
                table.insert( recipe.itemsStruct, {
                    item = {
                        type = name
                    },
                    count = count
                } )
            end

            recipe.count = recipe.count or 1
        end
        category.categoryID = catID

        category.crafterType = category.crafterType or "normal"

        category.minTier = minRecipeTier == 1000 and 1 or minRecipeTier
    end
end )

function cft.addCategory( name, icon, crafterType, index )
    local categories = GAMEMODE.Config.Crafting.RECIPES
    table.insert( categories, index or #categories, {
        name = name,
        icon = icon,
        crafterType = crafterType,
        recipes = {}
    } )
end

function cft.addRecipe( categoryName, item, count, ingredients, timeToCraft, tier )
    local category
    for k, v in pairs( GAMEMODE.Config.Crafting.RECIPES ) do
        if v.name == categoryName then
            category = v
        end
    end

    if not category then
        error( "No category with name " .. categoryName )
    end

    table.insert( category.recipes, {
        item = item,
        count = count or 1,
        ingredients = ingredients,
        tier = tier,
        timeToCraft = timeToCraft
    } )
end
