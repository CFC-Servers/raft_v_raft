RVR = RVR or {}
RVR.Localization = {}
local L = RVR.Localization

local lang = ( GAMEMODE or GM ).Config.Localization.LANGUAGE

L.Localize = function( key, ... )
    if not L[key] then
        error( "Localization key " .. key .. " doesn't exist" )
    end
    if not L[key][lang] then
        error( "Language " .. lang .. " is invalid!" )
    end
    return string.format( L[key][lang], ... )
end

-- Call a generic localization to trigger an error if language is invalid
hook.Add( "Initialize", "RVR_LocalizationCheck", function()
    L.Localize( "storage" )
end )

-- Words
L.storage = {
    en = "Storage",
    fr = "Espace de rangement"
}

L.mediumStorage = {
    en = "Medium Storage",
    fr = "<UNKNOWN>"
}

-- Error messages
L.notHoldingItem = {
    en = "Not holding an item",
    fr = "Aucun item sélectionné"
}

L.itemDoesNotExist = {
    en = "Item %s does not exist",
    fr = "L'item %s n'éxiste pas"
}

L.noSpaceInInventory = {
    en = "No space in inventory",
    fr = "L'inventaire est plein"
}

L.canOnlyFitAmount = {
    en = "Only able to fit %i of %i items in inventory",
    fr = "Seulement %i des %i items on été placé dans l'inventaire"
}

L.cantGiveLessThanOne = {
    en = "Cannot give less than 1 item, what are you expecting to happen?",
    fr = "Impossible de donner moins d'un item, comment penses-tu que ça fonctionnerait?"
}

L.itemTypeDoesNotExist = {
    en = "Item type %s does not exist",
    fr = "L'item de type %s n'éxiste pas"
}

L.invalidInt = {
    en = "Invalid integer: %s",
    fr = "<UNKNOWN>"
}

L.invalidFloat = {
    en = "Invalid float: %s",
    fr = "<UNKNOWN>"
}

L.invalidBool = {
    en = "Invalid boolean: %s",
    fr = "<UNKNOWN>"
}

L.notAimingAtPlayer = {
    en = "Not currently aiming at a player!",
    fr = "<UNKNOWN>"
}

L.invalidPlayer = {
    en = "Invalid player: %s",
    fr = "<UNKNOWN>"
}

L.multiplePlayerMatch = {
    en = "\"%s\" matches multiple players:\n%s",
    fr = "<UNKNOWN>"
}

L.missingArgumentAndUsage = {
    en = "Missing argument. Usage: %s",
    fr = "<UNKNOWN>"
}

L.insufficientUserGroup = {
    en = "You need to be %s to use this command",
    fr = "<UNKNOWN>"
}

L.description = {
    en = "Description",
    fr = "<UNKNOWN>"
}

L.unknownCommand = {
    en = "Command \"%s\" does not exist",
    fr = "<UNKNOWN>"
}

L.commandsInConsole = {
    en = "Look in console for a list of commands.",
    fr = "<UNKNOWN>"
}