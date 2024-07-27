
## WHEN I COME BACK

* Finish the final sprites
* Finish tutorial + close game loop
  * So I can **test it as is**, maybe it's already hard enough and all my tweaks are unnecessary.
  * So I can think about a way so I only need "1 tutorial image per level", instead of requiring a bunch of them at the very first level.
* Then just try all those other rules (with config toggle for easy on/off) and really finetune the core gameplay.


TUTORIAL 1: Pick up ingredients by moving over them. Give people what they want before their timer runs out. (If you visit a customer with the wrong thing, you lose everything you're holding.)
=> Stage is just littered with separate ingredients. No machines yet.

TUTORIAL 2: Recipes


## Codebase / Structure

* (CONFIG TOGGLE) What you just delivered leaves a shadow
  * Save "prev_delivered_ingredients" inside some other module
  * The Shadow stuff reads it, so it knows what to allow through
  * Other modules read it, as needed, to modify their movement/parameters/etcetera

* (CONFIG) Control the number of times a machine can appear
  * Nah, this should just be on the GDict _data_.
  * And one "scalar" for this based on player count?
  * Then, when generating map, randomly pick within range and stick to it

* SPIKES:
  * A submodule on progression to handle these (tick update, add if not at max, all Spikes are in some group)
  * A module on player that checks if we walked over one

* TELEPORT:
  * Spawn (at least) 2 during map generation
  * A module on player that checks if we're on one, then moves us?


### Order Modifiers

Perhaps orders can take one extra property in later levels, such as ...

* COOP SOLUTION: Orders can only be delivered by the right person? (They show a player color as well?)
* MAYBE SOLUTION: Some people want a _crossmark potion_. They will be satisfied if you deliver anything that is NOT a good recipe.

### Feedback stuff I shouldn't forget

* Feedback when certain things happen/are not allowed
* Sparkles when something MUTATES in shadow


### Wildcard

* Add another machine.
* It displays the (randomly picked) Wildcard of this round. (Walking through it CHANGES the wildcard.)
* In match-checking, properly handle this wildcard (like I did with boardgames before)



## Visuals

* TUTORIAL: Already test it to see how difficult it is to explain the game.
  * And probably also code its integration, delaying orders until that's explained, etcetera.
* SPRITES:
  * Potions & machines
  * Player sprites?

## Later Stuff

* Scale numbers based on player count (map size, number of orders, etcetera)
* Menu, input select, in-between screens
* Those other ideas that should make it more like a roguelite and more thematic (keeping a shadow of what you just delivered, what you throw in the garbage determines next round, etcetera.)

* Improve `PlayerShadow` module
  * It tracks any filters/exceptions (from previous potions)
  * Modulate slightly based on player color?
* How to neatly display what's inside garbage?
  * Create separate display option on inventory to GROUP elements by type and display a NUMBER for how many there are!