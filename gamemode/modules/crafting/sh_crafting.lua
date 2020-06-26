RVR.Crafting = RVR.Crafting or {}
RVR.Crafting.Recipes = {
    {
        categoryName = "Weapons",
        icon = "rvr/icons/food.png",
        recipes = {
            {
                item = "wood",
                ingredients = {
                    nail = 5
                },
                timeToCraft = 3,
            }
        }
    },
    {
        categoryName = "Tools",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        categoryName = "Other",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        categoryName = "Equipment",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        categoryName = "Resources",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        categoryName = "Navigation",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        categoryName = "Furniture",
        icon = "rvr/icons/food.png",
        recipes = {}
    }
}


for _, category in ipairs( RVR.Crafting.Recipes ) do
    local categoryTier = 1000
    for _, recipe in pairs( category.recipes ) do
        recipe.tier = recipe.tier or 1
        if recipe.tier < categoryTier then
            categoryTier = recipe.tier
        end
    end

    category.minTier = categoryTier == 1000 and 1 or categoryTier
end

if SERVER then
    include( "crafting/sv_crafting.lua" )
    AddCSLuaFile( "crafting/cl_crafting.lua" )
end

if CLIENT then
    include( "crafting/cl_crafting.lua" )
end