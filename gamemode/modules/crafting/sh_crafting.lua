RVR.Crafting = RVR.Crafting or {}
RVR.Crafting.Recipes = {
    {
        categoryName = "Weapons",
        icon = "rvr/icons/food.png",
        recipes = {
            -- {
            --     item = "spear",
            --     description = "",
            --     ingredients = {
            --         rvr_plank = 8,
            --         rvr_rope = 3
            --     },
            --     timeToCraft = 10
            -- }
        }
    },
    {
        categoryName = "Tools",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    },
    {
        categoryName = "Other",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    },
    {
        categoryName = "Equipment",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    },
    {
        categoryName = "Resources",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    },
    {
        categoryName = "Navigation",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    },
    {
        categoryName = "Furniture",
        icon = "rvr/icons/food.png",
        recipes = {
        }
    }
}

if SERVER then
    include( "crafting/sv_crafting.lua" )
    AddCSLuaFile( "crafting/cl_crafting.lua" )
end

if CLIENT then
    include( "crafting/cl_crafting.lua" )
end