RVR = RVR or {}
RVR.Localization = {}
local L = RVR.Localization

L.Localize = function( key, ... )
    local lang = GAMEMODE.Config.Localization.Language
    return string.format( L[key][lang], ... )
end

-- Words
L.storage = {
    en = "Storage",
    fr = "Espace de rangement"
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
