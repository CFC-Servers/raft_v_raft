RVR.Crafting = RVR.Crafting or {}
local cft = RVR.Crafting

util.AddNetworkString( "RVR_Crafting_AttemptCraft" )
util.AddNetworkString( "RVR_Crafting_CraftResponse" )
util.AddNetworkString( "RVR_Crafting_CloseCraftingMenu" )
util.AddNetworkString( "RVR_Crafting_OpenCraftingMenu" )
util.AddNetworkString( "RVR_Crafting_Grab" )

local function craftFail( ply )
    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteInt( cft.STATE_WAITING, 4 )
    net.Send( ply )
end

net.Receive( "RVR_Crafting_Grab", function( len, ply )
    local ent = ply.RVR_CraftingEnt or ply

    if not ent.RVR_Crafting then return end

    local state = cft.STATE_WAITING

    local output = ent.RVR_Crafting.output
    if output then
        if CurTime() >= output.timeStart + output.recipe.timeToCraft then
            local recipe = output.recipe
            local itemInstance = RVR.Items.getItemInstance( recipe.item )

            if RVR.Inventory.canFitItem( ply.RVR_Inventory, itemInstance, recipe.count ) then
                RVR.Inventory.attemptPickupItem( ply, itemInstance, recipe.count )
                ent.RVR_Crafting.output = nil
            else
                state = cft.STATE_CRAFTED
            end
        else
            state = cft.STATE_CRAFTING
        end
    end

    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteInt( state, 4 )
    net.Send( ply )
end )

net.Receive( "RVR_Crafting_AttemptCraft", function( len, ply )
    local categoryID = net.ReadInt( 8 )
    local recipeID = net.ReadInt( 8 )

    local category = RVR.Crafting.Recipes[categoryID]
    if not category then return craftFail( ply ) end

    local recipe = category.recipes[recipeID]
    if not recipe then return craftFail( ply ) end

    local craftingEnt = ply.RVR_CraftingEnt or ply

    if not cft.craft( ply, craftingEnt, recipe ) then craftFail( ply ) end
end )

function cft.craft( ply, ent, recipe )
    if not ent.RVR_Crafting then return end

    if ent.RVR_Crafting.output then return end

    local tier = ent.RVR_Crafting.tier
    if tier < recipe.tier then return end

    local success = RVR.Inventory.tryTakeItems( ply, recipe.itemsStruct )
    if not success then return end

    ent.RVR_Crafting.output = {
        recipe = recipe,
        timeStart = CurTime(),
    }

    net.Start( "RVR_Crafting_CraftResponse" )
    net.WriteInt( cft.STATE_CRAFTING, 4 )
    net.Send( ply )

    return true
end

function cft.openMenu( ply, ent )
    if not ent.RVR_Crafting then return end

    local craftData = { state = cft.STATE_WAITING }

    local output = ent.RVR_Crafting.output
    if output then
        local recipe = output.recipe

        if CurTime() >= output.timeStart + recipe.timeToCraft then
            craftData.state = cft.STATE_CRAFTED
        else
            craftData.state = cft.STATE_CRAFTING
        end
        craftData.timeStart = output.timeStart

        craftData.categoryID = recipe.categoryID
        craftData.recipeID = recipe.recipeID
    end

    craftData.tier = ent.RVR_Crafting.tier
    craftData.name = ent.RVR_Crafting.name
    craftData.ent = ent

    net.Start( "RVR_Crafting_OpenCraftingMenu" )
    net.WriteTable( craftData )
    net.Send( ply )

    ply.RVR_CraftingEnt = ent
end

function cft.makeCrafter( ent, name, tier )
    ent.RVR_Crafting = {
        tier = tier,
        name = name,
    }
end

hook.Add( "PlayerInitialSpawn", "RVR_Crafting_addCrafter", function( ply )
    cft.makeCrafter( ply, "Player", 1 )
end )

net.Receive( "RVR_Crafting_CloseCraftingMenu", function( len, ply )
    ply.RVR_CraftingEnt = nil
end )

net.Receive( "RVR_Crafting_OpenCraftingMenu", function( len, ply )
    cft.openMenu( ply, ply )
end )
