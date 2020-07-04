RVR = RVR or {}
RVR.Localization = {}
local L = RVR.Localization

L.Localize = function( key, ... )
    local lang = GAMEMODE.Config.Localization.Language
    return string.format( L[key][lang], ... )
end

-- Words
L.storage = {
    en = "storage",
    fr = "Je suis une baguette"
}

-- Error messages
L.notHoldingItem = {
    en = "Not holding an item",
    fr = "Je suis une baguette"
}

L.itemDoesNotExist = {
    en = "Item %s does not exist",
    fr = "Je suis une %s"
}

L.noSpaceInInventory = {
    en = "No space in inventory",
    fr = "Je suis une baguette"
}

L.canOnlyFitAmount = {
    en = "Only able to fit %i of %i items in inventory",
    fr = "Je suis %i baguettes %i"
}

L.cantGiveLessThanOne = {
    en = "Canot give less than 1 item, what are you expecting to happen?",
    fr = "Je suis une baguette?"
}

L.itemTypeDoesNotExist = {
    en = "Item type %s does not exist",
    fr = "Je suis une %s"
}


