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
                timeToCraft = 39,
                ingredients = {
                    dirty_water = 1
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
                timeToCraft = 5,
                ingredients = {
                    tuna = 1,
                    wood = 1
                }
            },
            {
                item = "cooked_horse_mackerel",
                timeToCraft = 3,
                ingredients = {
                    horse_mackerel = 1,
                    wood = 1
                }
            }
        }
    },
    {
        name = "Weapons",
        icon = "rvr/icons/craftingmenu_category_weapons.png",
        recipes = {
            {
                item = "wooden_axe",
                timeToCraft = 5,
                ingredients = {
                    wood = 10
                }
            },
            {
                item = "stone_axe",
                timeToCraft = 10,
                ingredients = {
                    wood = 10,
                    big_rock = 1,
                    rope = 1
                }
            },
            {
                item = "metal_axe",
                timeToCraft = 30,
                tier = 2,
                ingredients = {
                    wood = 15,
                    iron = 20
                }
            },
            {
                item = "wooden_spear",
                timeToCraft = 10,
                ingredients = {
                    wood = 15
                }
            },
            {
                item = "stone_spear",
                timeToCraft = 20,
                tier = 2,
                ingredients = {
                    wood = 20,
                    big_rock = 1,
                    rope = 1
                }
            },
            {
                item = "metal_spear",
                timeToCraft = 45,
                tier = 2,
                ingredients = {
                    wood = 20,
                    iron = 2
                }
            },
            {
                item = "sword",
                timeToCraft = 60,
                tier = 2,
                ingredients = {
                    wood = 20,
                    cloth = 2,
                    iron = 5
                }
            },
        }
    },
    {
        name = "Tools",
        icon = "rvr/icons/craftingmenu_category_tools.png",
        recipes = {
            {
                item = "raft_builder",
                timeToCraft = 20,
                ingredients = {
                    big_rock = 1,
                    nail = 1,
                    wood = 5
                }
            },
            {
                item = "paddle",
                timeToCraft = 15,
                ingredients = {
                    wood = 50,
                    nail = 1,
                    rope = 1
                }
            },
            {
                item = "binoculars",
                timeToCraft = 15,
                tier = 2,
                ingredients = {
                    straw = 5,
                    wood = 5,
                    cloth = 1
                }
            },
            {
                item = "tape",
                timeToCraft = 10,
                tier = 2,
                ingredients = {
                    cloth = 20,
                    straw = 5
                }
            }
        }
    },
    {
        name = "Resources",
        icon = "rvr/icons/craftingmenu_category_resources.png",
        recipes = {
            {
                item = "big_rock",
                timeToCraft = 10,
                ingredients = {
                    small_rocks = 10
                }
            },
            {
                item = "rope",
                timeToCraft = 15,
                ingredients = {
                    cloth = 15
                }
            },
            {
                item = "iron",
                timeToCraft = 10,
                ingredients = {
                    scrap_metal = 10
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
                timeToCraft = 10,
                ingredients = {
                    cloth = 5
                }
            },
            {
                item = "medkit",
                timeToCraft = 15,
                tier = 2,
                ingredients = {
                    bandage = 4,
                    water = 1,
                    rope = 1
                }
            },
        }
    },
    -- {
    --     name = "Equipment",
    --     icon = "rvr/icons/craftingmenu_category_armor.png",
    --     recipes = {}
    -- },
    -- {
    --     name = "Navigation",
    --     icon = "rvr/icons/craftingmenu_category_navigation.png",
    --     recipes = {}
    -- },
    {
        name = "Furniture",
        icon = "rvr/icons/craftingmenu_category_furniture.png",
        recipes = {
            {
                item = "storage_box_small",
                timeToCraft = 10,
                ingredients = {
                    wood = 30,
                    nail = 10
                }
            },
            {
                item = "storage_box",
                timeToCraft = 20,
                tier = 2,
                ingredients = {
                    wood = 50,
                    nail = 20,
                    rope = 5
                }
            },
            {
                item = "storage_box_large",
                timeToCraft = 30,
                tier = 2,
                ingredients = {
                    wood = 60,
                    nail = 30,
                    rope = 10,
                    iron = 2
                }
            },
            {
                item = "workbench",
                timeToCraft = 10,
                ingredients = {
                    wood = 20,
                    nail = 5,
                    scrap_metal = 1
                }
            },
            {
                item = "water_purifier",
                timeToCraft = 15,
                tier = 2,
                ingredients = {
                    wood = 20,
                    cloth = 10,
                    nail = 5
                }
            },
            {
                item = "grill",
                timeToCraft = 15,
                tier = 2,
                ingredients = {
                    scrap_metal = 10,
                    wood = 10,
                    rope = 2
                }
            }
        }
    },
    -- {
    --     name = "Other",
    --     icon = "rvr/icons/craftingmenu_category_other.png",
    --     recipes = {}
    -- }
}
