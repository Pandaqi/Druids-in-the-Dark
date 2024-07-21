
## Codebase / Structure

* Create that GConfig file, move all values, randomization, rules on/off toggles onto it

## Shadows

* Create a `PlayerShadow` module
  * It tracks the shadow range
  * It tracks any filters/exceptions (from previous potions)
  * It has a simple black circle sprite that is scaled to match this range, slightly transparent

## Visuals

* TUTORIAL: Already test it to see how difficult it is to explain the game.
  * And probably also code its integration, delaying orders until that's explained, etcetera.
* INVENTORY: Display
  * Also the slightly different versions on Recipe Book and Order Cell
    * Order Cell just displays a single potion each time + order timer
    * Recipe Book just displays an inventory + (=>) the end result as well 
      * Potentially the recipe is just ABOVE and the end result BELOW.
    * YES, this should all just REUSE the same ModuleInventory
* SPRITES: Everything
  * Elements, potions, machines
  * Player sprites, cell sprites

## Later Stuff

* Scale numbers based on player count (map size, number of orders, etcetera)
* Menu, input select, in-between screens
* Those other ideas that should make it more like a roguelite and more thematic (keeping a shadow of what you just delivered, what you throw in the garbage determines next round, etcetera.)
  * Advanced Mechanic = you first have to walk through the customer before you can see the order they want? (Like in PlateUp: asking what they want first.)