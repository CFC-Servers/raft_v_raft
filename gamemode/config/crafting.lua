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
        name = "Water",
        icon = "rvr/icons/craftingmenu_category_food.png",
        crafterType = "water",
        recipes = {
            {
                item = "water",
                count = 1,
                timeToCraft = 39,
                ingredients = {
                    dirty_water =  1
                }
            }
        }
    },
    {
        name = "Grill",
        icon = "rvr/icons/craftingmenu_category_food.png",
        crafterType = "cooking",
        recipes = {
            {
                item = "cooked_tuna",
                count = 1,
                timeToCraft = 5,
                ingredients = {
                    tuna = 1,
                    wood = 1
                }
            }
        }
    },
    {
        name = "Weapons",
        icon = "rvr/icons/craftingmenu_category_weapons.png",
        recipes = {}
    },
    {
        name = "Tools",
        icon = "rvr/icons/craftingmenu_category_tools.png",
        recipes = {
            {
                item = "raft_builder",
                count = 1,
                timeToCraft = 20,
                ingredients = {
                    big_rock = 1,
                    nail = 1,
                    wood = 5
                }
            },
        }
    },
    {
        name = "Resources",
        icon = "rvr/icons/craftingmenu_category_resources.png",
        recipes = {
            {
                item = "big_rock",
                count = 1,
                timeToCraft = 10,
                ingredients = {
                    small_rocks = 10
                }
            },
            {
                item = "rope",
                count = 1,
                timeToCraft = 15,
                ingredients = {
                    cloth = 15
                }
            },
            {
                item = "iron",
                count = 1,
                timeToCraft = 10,
                ingredients = {
                    small_rocks = 10
                }
            },
        }
    },
    {
        name = "Medical",
        icon = "rvr/icons/craftingmenu_category_medical.png",
        recipes = {
            {
                item = "bandage",
                count = 1,
                timeToCraft = 10,
                ingredients = {
                    cloth = 5
                }
            },
            {
                item = "medkit",
                count = 1,
                timeToCraft = 15,
                ingredients = {
                    bandage = 4,
                    water = 1,
                    rope = 1
                }
            },
        }
    },
    {
        name = "Equipment",
        icon = "rvr/icons/craftingmenu_category_armor.png",
        recipes = {}
    },
    -- {
    --     name = "Navigation",
    --     icon = "rvr/icons/craftingmenu_category_navigation.png",
    --     recipes = {}
    -- },
    -- {
    --     name = "Furniture",
    --     icon = "rvr/icons/craftingmenu_category_furniture.png",
    --     recipes = {}
    -- },
    {
        name = "Other",
        icon = "rvr/icons/craftingmenu_category_other.png",
        recipes = {}
    }
}
