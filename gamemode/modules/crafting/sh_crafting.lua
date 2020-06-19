RVR.Crafting = RVR.Crafting or {}
RVR.Crafting.Recipes = {
    {
        categoryName = "Weapons",
        icon = "",
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
        icon = "",
        recipes = {
        }
    },
    {
        categoryName = "Other",
        icon = "",
        recipes = {
        }
    },
    {
        categoryName = "Equipment",
        icon = "",
        recipes = {
        }
    },
    {
        categoryName = "Resources",
        icon = "",
        recipes = {
        }
    },
    {
        categoryName = "Navigation",
        icon = "",
        recipes = {
        }
    },
    {
        categoryName = "Furniture",
        icon = "",
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