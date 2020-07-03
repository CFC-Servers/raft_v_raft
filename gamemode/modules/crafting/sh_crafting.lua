RVR.Crafting = RVR.Crafting or {}
local cft = RVR.Crafting

cft.STATE_WAITING = 0
cft.STATE_CRAFT_REQUEST = 1
cft.STATE_CRAFTING = 2
cft.STATE_CRAFTED = 3
cft.STATE_GRAB_REQUEST = 4

for catID, category in ipairs( cft.Recipes ) do
    local categoryTier = 1000
    for recipeID, recipe in pairs( category.recipes ) do
        recipe.tier = recipe.tier or 1
        if recipe.tier < categoryTier then
            categoryTier = recipe.tier
        end

        recipe.categoryID = catID
        recipe.recipeID = recipeID

        recipe.itemsStruct = {}
        for name, count in pairs( recipe.ingredients ) do
            table.insert( recipe.itemsStruct, { item = { type = name }, count = count } )
        end

        recipe.count = recipe.count or 1
    end
    category.categoryID = catID

    category.minTier = categoryTier == 1000 and 1 or categoryTier
end
