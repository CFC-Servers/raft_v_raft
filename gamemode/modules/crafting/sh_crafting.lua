RVR.Crafting = RVR.Crafting or {}
RVR.Crafting.Recipes = {
    {
        categoryName = "Weapons",
        icon = "icons/items/nail.png",
        recipes = {
            {
                item = "rvr_spear",
                description = "",
                ingredients = {
                    rvr_plank = 8,
                    rvr_rope = 3
                },
                timeToCraft = 10
            }
        }
    },
    {
        categoryName = "Tools",
        icon = "icons/items/nail.png",
        recipes = {
        }
    },
    {
        categoryName = "Other",
        icon = "icons/items/nail.png",
        recipes = {
        }
    },
    {
        categoryName = "Equipment",
        icon = "icons/items/nail.png",
        recipes = {
        }
    },
    {
        categoryName = "Resources",
        icon = "icons/items/nail.png",
        recipes = {
        }
    },
    {
        categoryName = "Navigation",
        icon = "icons/items/nail.png",
        recipes = {
        }
    },
    {
        categoryName = "Furniture",
        icon = "icons/items/nail.png",
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