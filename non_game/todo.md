
## Tutorial Overview

TUTORIAL 1: Pick up ingredients by moving over them. Give people what they want before their timer runs out. (If you visit a customer with the wrong thing, you lose everything you're holding.)
=> Stage is just littered with separate ingredients. No machines yet.

TUTORIAL 2: Recipes

### Gameplay Loop

* @TODO: Button/Hint for dismissing tutorial
* @TODO: Properly _reset_ everything (without leaving the scene) for next level
* @TODO: Proper game over screen (both win/lose)

* @BUG: You still _remove_ stuff even if you don't actually pick it up because inventory is full

### Order Modifiers

Perhaps orders can take one extra property in later levels, such as ...

* COOP SOLUTION: Orders can only be delivered by the right person? (They show a player color as well?)
* MAYBE SOLUTION: Some people want a _crossmark potion_. They will be satisfied if you deliver anything that is NOT a good recipe.

### Feedback stuff I shouldn't forget

* Feedback when certain things happen/are not allowed
* Sparkles when something MUTATES in shadow
* Potentially extend the non_interact to spikes/wildcard too => give permanent feedback of this to player?

## Visuals

* SPRITES:
  * Potions & machines
  * Player sprites?
  * 9-patch-rect + other UI
  * Tutorials => one long row of 128x128 sprites? => Once done, properly load it in Tutorial

## Later Stuff

* Menu, input select, in-between screens
* Those other ideas that should make it more like a roguelite and more thematic (what you throw in the garbage determines next round, ability to buy new planters to get ingredients more consistently, etcetera.)
