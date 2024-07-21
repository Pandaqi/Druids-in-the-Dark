
## WHEN I COME BACK (Thursday?)

* Finish the final sprites + inventory
* Finish tutorial + close game loop
  * So I can **test it as is**, maybe it's already hard enough and all my tweaks are unnecessary.
  * So I can think about a way so I only need "1 tutorial image per level", instead of requiring a bunch of them at the very first level.
* Then just try all those other rules (with config toggle for easy on/off) and really finetune the core gameplay.


TUTORIAL 1: Pick up ingredients by moving over them. Give people what they want before their timer runs out. (If you visit a customer with the wrong thing, you lose everything you're holding.)
=> Stage is just littered with separate ingredients. No machines yet.

TUTORIAL 2: Recipes


## Codebase / Structure

* Create that GConfig file, move all values (such as CELL_SIZE), randomization, rules on/off toggles onto it
* Should probably limit how "full" the map may be in general. (To ensure walkability and prevent overwhelming people.)
* @BUG: Because order isn't guaranteed, new ingredients can still appear inside your shadow if you're really unlucky (it only updates shadow cells AFTER already placing the new ingredients) => fix this by deferring the other calls?
* @GAMEPLAY ISSUE: Because things decompose into the required ingredients ... it's very easy to fulfill recipes of course. There's no element of combining them into something _new_, because you already _have everything you need_.
  * BAD SOLUTION: If we simply don't make certain potions appear naturally, we might never have the ingredients to fulfill it ...
  * OKAY SOLUTION: Random element spawns right from the start. (You only "control" it later with the plants.)
  * COOP SOLUTION: Use unique roles or something so that different players must collect different ingredients ...
  * COOP SOLUTION: Orders can only be delivered by the right person? (They show a player color as well?)
  * MAYBE SOLUTION: Harsher movement penalties? For example, moving onto an order while having the WRONG stuff makes you lose all of it. Many "bad things" appear at random and you have to keep track of them or you'll run into them. Whenever you break a potion, there's a chance of getting random garbage as well?
    * **Just have way more garbage bins?**
  * MAYBE SOLUTION: Some people want a _question mark potion_. They will be satisfied if you deliver anything that is NOT a good recipe.
  * **WACKY SOLUTION** (but maybe good): every time you move over a recipe book, you _change the recipes_. => Every time you've delivered a recipe, it's struck out and replaced?
  * **WACKY SOLUTION** (but maybe good): the longer/more often an order/element is in shadow, the more likely it is to _mutate_ (change to something else) => the fact it mutated is SHOWN/REVEALED with particles and stuff, but what it changed to is not
  * MAYBE SOLUTION: Any time you walk over an order with the wrong thing, the LOCATIONS of several tiles (such as garbage bins) changes to random new (non-shadow) cells.
    * This might be GOOD anyway, because it provides a way to get out of "impossible situations" (getting stuck due to random level layout)
  * **STRAIGHTFORWARD SOLUTION:** Customers simply want multiple potions. They can ask for a finished thing. They can ask for a component only. They can ask for _two_ things, which means they only want the components in the recipe that overlap?
    * A "wildcard" component/potion/order feels like it might do wonders here ...
  * MAYBE by walking through an order, you can LENGTHEN its timer? (Knowing you won't be able to fulfill it yet, you can delay and delay until you can.)
  * **WACKY SOLUTION:** You can't enter cells with ingredients that nobody currently wants? => Picking up an ingredient nobody needs is an instant death/penalty/whatever?
  * **WACKY SOLUTION:** You _can_ walk into disabled cells. It simply means you die.
* @GAMEPLAY ISSUE RELATED: We can't really do moving threats or threats that spawn in shadows, because then you simply DON'T KNOW why you died or what happened ...

## Visuals

* TUTORIAL: Already test it to see how difficult it is to explain the game.
  * And probably also code its integration, delaying orders until that's explained, etcetera.
* INVENTORY: Display
  * Also the slightly different versions on Recipe Book and Order Cell
    * Order Cell just displays a single potion each time + order timer
    * Recipe Book just displays an inventory + (=>) the end result as well 
      * Potentially the recipe is just ABOVE and the end result BELOW.
    * YES, this should all just REUSE the same ModuleInventory
* SPRITES:
  * Potions & machines
  * Player sprites?

## Later Stuff

* Scale numbers based on player count (map size, number of orders, etcetera)
* Menu, input select, in-between screens
* Those other ideas that should make it more like a roguelite and more thematic (keeping a shadow of what you just delivered, what you throw in the garbage determines next round, etcetera.)
  * Advanced Mechanic = you first have to walk through the customer before you can see the order they want? (Like in PlateUp: asking what they want first.)

* Improve `PlayerShadow` module
  * It tracks any filters/exceptions (from previous potions)
  * Modulate slightly based on player color?
