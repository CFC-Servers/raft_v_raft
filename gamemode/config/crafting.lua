GM.Config = GM.Config or {}
GM.Config.Crafting = GM.Config.Crafting or {}

local config = GM.Config.Crafting
--[[

Recipe structure

Recipes = { categories }

category = {
    name = Name of category
    icon = Path to icon for category, from materials/
    crafterType = (optional) Type of crafter required for this category, defaults to "normal"
    recipes = { recipes }
}

recipe = {
    item = Output item type
    count = (optional) Number of items to give, defaults to 1
    ingredients = {
        ingredient1Type = count1
        ingredient12ype = count2
    }
    tier = (optional) Minimum crafter tier required, defaults to 1
    timeToCraft = Time in seconds this craft takes (non-zero)
}

]]

config.RECIPES = {
    {
        name = "Weapons",
        icon = "rvr/icons/craftingmenu_category_weapons.png",
        recipes = {
            {
                item = "wood",
                count = 4,
                ingredients = {
                    nail = 5,
                    wood = 3,
                },
                timeToCraft = 120,
            },
            {
                item = "wood",
                ingredients = {
                    nail = 5,
                },
                timeToCraft = 3,
            },
            {
                item = "wood",
                ingredients = {
                    nail = 5,
                },
                timeToCraft = 3,
            },
        },
    },
    {
        name = "Tools",
        icon = "rvr/icons/craftingmenu_category_tools.png",
        recipes = {
            {
                item = "wood",
                ingredients = {
                    nail = 5
                },
                timeToCraft = 3,
            },
        },
    },
    {
        name = "Food",
        icon = "rvr/icons/craftingmenu_category_weapons.png",
        recipes = {},
    },
    {
        name = "Resources",
        icon = "rvr/icons/craftingmenu_category_resources.png",
        recipes = {},
    },
    {
        name = "Equipment",
        icon = "rvr/icons/craftingmenu_category_armor.png",
        recipes = {},
    },
    {
        name = "Navigation",
        icon = "rvr/icons/craftingmenu_category_navigation.png",
        recipes = {},
    },
    {
        name = "Furniture",
        icon = "rvr/icons/craftingmenu_category_furniture.png",
        recipes = {},
    },
    {
        name = "Other",
        icon = "rvr/icons/craftingmenu_category_other.png",
        recipes = {},
    },
}
