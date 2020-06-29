RVR.Crafting = RVR.Crafting or {}
RVR.Crafting.Recipes = {
    {
        name = "Weapons",
        icon = "rvr/icons/food.png",
        recipes = {
            {
                item = "wood",
                ingredients = {
                    nail = 5
                },
                timeToCraft = 3,
            },
            {
                item = "wood",
                ingredients = {
                    nail = 5
                },
                timeToCraft = 3,
            },
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
        name = "Tools",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        name = "Other",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        name = "Equipment",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        name = "Resources",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        name = "Navigation",
        icon = "rvr/icons/food.png",
        recipes = {}
    },
    {
        name = "Furniture",
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