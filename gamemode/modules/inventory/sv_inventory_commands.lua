local function giveItem( caller, target, item, count )
    if count < 1 then
        return "Cannot give less than 1 item, what are you expecting to happen?"
    end

    local success, amount = RVR.Inventory.attemptPickupItem( target, item, count )
    if success then return end

    if amount == 0 then
        return "No space in inventory"
    end

    return "Only able to fit " .. amount .. " of " .. count .. " items in inventory."
end

local function giveSingle( caller, target, item )
    return giveItem( caller, target, item, 1 )
end

hook.Add( "RVR_ModulesLoaded", "RVR_Inventory_AddCommands", function()
    RVR.Commands.addType( "item", function( str, caller )
        -- Gets currently held item
        if str == "^" then
            local itemInstance = RVR.Inventory.getSelectedItem( caller )
            if not itemInstance then
                return nil, "Not holding an item"
            end

            str = itemInstance.type
        end

        local itemData = RVR.Items.getItemData( str )

        if not itemData then
            return nil, "Item " .. str .. " does not exist"
        end

        return itemData
    end )

    RVR.Commands.register(
        "give",
        { "Target", "Item", "Count" },
        { "player", "item", "int" },
        RVR_USER_ADMIN,
        giveItem,
        "Gives a player item(s)"
    )

    RVR.Commands.register(
        { "givesingle", "give1", "giveone" },
        { "Target", "Item" }, { "player", "item" },
        RVR_USER_ADMIN,
        giveSingle,
        "Gives a player an item"
    )
end )
