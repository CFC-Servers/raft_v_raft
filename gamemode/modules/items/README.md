# Items
## Functions
- `RVR.Items.getItemData( itemType )`  
Gets the full item data for a given item type
- `RVR.Items.getItemInstance( itemType )`  
Creates a simple table for an item instance, currently just `{ type = itemType }`, intended to be extended with item metadata like durability in the future.

## Item structure
- `type` - (string) Unique name for item
- `displayName` - (string) Name used in menus
- `description` - (string) Description
- `maxCount` - (int) Max stack size in inventories
- `model` - (string) Dropped item + held item model
- `icon` - (string) Inventory icon
- `isHeadGear` - (bool) Can this be equipped in head slot
- `isBodyGear` - (bool) Can this be equipped in body slot
- `isFootGear` - (bool) Can this be equipped in foot slot
- `stackable` - (bool) Can this be stacked in inventory or as dropped item,
- `swep` - (string) Name of custom swep to use for this item
- `viewModelOffset` - (vector) Clientside viewmodel offset
- `viewModelAng` - (ang) clientside viewmodel angle
- `worldModelOffset` - (vector) Clientside worldmodel offset
- `worldModelAng` - (ang) clientside worldmodel angle
- `consumable` - (bool) Can this item be consumed
- `food` - (int) Food value of this item, requires consumable
- `water` - (int) Water value of this item, requires consumable
- `health` - (int) Health value of this item, requires consumable
- `onConsume` - (function) What do when consume
