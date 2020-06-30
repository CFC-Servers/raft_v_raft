# Inventory
Inventory defined on RVR.Inventory (shared)  
Inventories are stored on the entity they belong to, under `RVR_Inventory` and are often of the structure:  
```
    {
        Inventory = {},
        MaxSlots = 10,
        InventoryType = "Box",
    }
```
Player inventories store extra data such as `HotbarSelected`, `CursorSlot` and gear slots.  
Inventory slots are fully defined by the entity and the slot number.  
Player inventories have special slots numbers:  
- `-1` - Cursor slot
- `MaxSlots + 1` - HeadGear slot
- `MaxSlots + 2` - BodyGear slot
- `MaxSlots + 3` - FootGear slot
## Server-side
All item transactions are done by specifying actions to do on slots, rather than having the client specify any information about the items themselves.  This reduces possibility of people cheating.
### Config
- `PLAYER_HOTBAR_SLOTS` - Number of slots on hotbar (probably shouldn't change)
- `PLAYER_INVENTORY_SLOTS` - Number of slots in inventory, good to keep this as a multiple of 4
- `ITEM_DESPAWN_TIME` - In seconds

### Functions
- `RVR.Inventory.tryTakeItems( ent, items )`
    Will take all items if it can, else none.
     - `ent` - Entity with inventory
     - `items` - Same structure as `RVR.Inventory.checkItems()`
     - Return: `success`, `itemsMissing`
- `RVR.Inventory.setSlot( ent, position, itemData, plysToNotify )`
     - `ent` - Entity with the inventory
     - `position` - Slot index, see above for special cases
     - `itemData` - `{ item = item, count = count }`
     - `plysToNotify` - Optional, should contain any players that could be looking at the inventory

- `RVR.Inventory.getSlot( ent, position )`
     - `ent` - Entity with the inventory
     - `position` - Slot index, see above for special cases
- `RVR.Inventory.attemptPickupItem( ply, item, count )`
     - `ply` - Player to pick up items
     - `item` - Item instance
     - `count` - Number of that item to pickup
     - Returns: `couldFitAll`, `amount`
- `RVR.Inventory.getSelectedItem( ply )`
     - Returns: `item`, `count`
- `RVR.Inventory.setSelectedItem( ply, idx )`
     - `ply` - Player to affect
     - `idx` - Hotbar position between `1` and `GAMEMODE.Config.Inventory.PLAYER_HOTBAR_SLOTS`
- `RVR.Inventory.moveItem( fromEnt, toEnt, fromPosition, toPosition, count )`  
Attempts to move an item from one ent + position to another.  
Note, fromEnt can be the same as toEnt, allowing moving items within an inventory.  
This function will check validity for you.  
    - `fromEnt` - Entity to take items from
    - `toEnt` - Entity to put items in
    - `fromPosition` - Slot index to take items from
    - `toPosition` - Slot index to put items in
    - `count` - Number of items to attempt to move
    - Returns: `success`, `error`
        - `success` - Boolean success value
        - `error` - String error if success is `false`
- `RVR.Inventory.dropItem( ply, position, count )`
    - `ply` - Player to drop items from (Cannot just be a storage box)
    - `position` - Position to drop item from
    - `count` - Number of items to drop from this position
    - Returns: `droppedItem` entity or nil if couldn't drop.
- `RVR.Inventory.playerOpenInventory( ply, inventoryEntity )`
    - `ply` - Player to open inventory for
    - `inventoryEntity` - Entity with inventory to open (can be self)

### Extra
The `RVR_PreventInventory` hook allows you to prevent a player from accessing an inventory.  
It's syntax is as follows:
`boolean GM:RVR_PreventInventory( Player ply, Entity inventoryEnt )`  
Return true to prevent access

## Shared
### Functions
- `RVR.Inventory.checkItems( inventory, items )`
    - `inventory` - Inventory to check, for example `ply.RVR_Inventory`
    - `items` - List of `{ item = item, count = count }`
    - Returns: `success`, `itemsMissing`
    - Example:
        ```
        RVR.Inventory.checkItems( player.GetAll()[1].RVR_Inventory, {
            { item = RVR.Items.getItemData( "wood" ), count = 10 },
            { item = RVR.Items.getItemData( "nail" ), count = 20 }
        } )
        ```
- `RVR.Inventory.getItemCount( inventory, itemType )`
    - `inventory` - Inventory to check, for eample `pl.RVR_Inventory`
    - `itemType` - Type of item to get count of
- `RVR.Inventory.canFitItem( inventory, item, count )`
    - `inventory` - Inventory to check, for eample `pl.RVR_Inventory`
    - `item` - Item instance
    - `count` - Item count

## Client-side
### Functions
- `RVR.Inventory.selfHasItems( items )`
    - `items` - List of `{ item = item, count = count }`
    - Returns: `success`, `itemsMissing`
- `RVR.Inventory.selfGetItemCount( itemType )`
    - `itemType` - Type of item to get count of
- `RVR.Inventory.selfCanFitItem( item, count )`
    - `item` - Item instance
    - `count` - Item count

### SWEPS
- `rvr_held_item`  
  - Dynamically sets its models based on net messages, used to show any model that doesn't have actions
- `rvr_hands`  
    - Not currently implemented, gotta grab from another branch.

### SENTS
- `rvr_dropped_item`  
    - Automatically despawns after some time (in config)
    - Automatically merges with other items on touch if same item type

- `rvr_storage`  
    - Base storage box
    - `ent:SetStorageName( name )` - Default: `"Medium Storage"`
    - `ent:SetMaxSlots( slotCount )` - Default: `50`

### Vgui elements
- `RVR_ItemSlot`  
    Specify entity, slot index, and initial item (optional), and this element will handle all item movement
    - `itemSlot:SetLocationData( ent, position )`
    - `itemSlot:SetItemData( item, count )` - Note, item here must be the full item data
    - `itemSlot:ClearItemData()`
- `RVR_InventoryScroller`  
    Specify an inventory, and optional start + end slot index, and this will build a scrolling inventory panel with all slots pre-setup.  
    **NOTE**: This panel will not setup until an inventory is set, be sure to set the inventory **LAST.**
    - `inventoryScroller:SetInventory( inventory, startSlot = 1, endSlot = inventory.MaxSlots )`
    - `inventoryScroller:SetSlotImage( img )` - For custom slot images
    - `inventoryScroller:SetBackgroundImage( img )` - For custom backgroung image
    - `inventoryScroller:SetSlotsPerRow( slotsPerRow )` - For grid layout, default: `4`