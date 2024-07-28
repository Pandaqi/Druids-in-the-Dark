
## Self-Playtest Results

* @QOL: Add setting to inventory to wrap automatically after 2/3 ingredients => put behind toggle, only use on players (not recipe books or stuff)
* Prevent spawning ingredient directly adjacent to order, if we can help it? (Or only when we don't have potions yet?)
* @QOL: Have recipe book show a recipe from the start => just read from GConfig.recipes_included directly, bypass Recipes
* @DOUBT: Should I just cut off the game at level 20 and say "you did it, you won the game!"?
* @DOUBT: Do keep a score? Which rewards you for delivering orders quickly (and punishes you for delivering wrong ones)?



## Gameplay Loop

* @TODO: Button/Hint for dismissing tutorial
* @TODO: Button/Hint for game over screen

### Menu

* Marketing Image/Logo of game

### Input Select

* Some way to actually start the game (such as pressing/holding a certain button to ready up)
* Show actual key hints
* Prettier

### Feedback stuff I shouldn't forget

* Feedback when certain things happen/are not allowed
* Particles when breaking stuff, when moving, when delivering, etcetera
* Sparkles/feedback when something MUTATES in shadow
* Potentially extend the non_interact to spikes/wildcard too => give permanent feedback of this to player?
  * This is completely INVISIBLE and thus USELESS unless I give clear feedback that you are currently "non-interactive curse"


## Later Stuff



## PUBLISHING (don't forget)

* Make Menu the main scene



# DISCARDED IDEAS

### Order Modifiers

Perhaps orders can take one extra property in later levels, such as ...

* COOP SOLUTION: Orders can only be delivered by the right person? (They show a player color as well?)
* MAYBE SOLUTION: Some people want a _crossmark potion_. They will be satisfied if you deliver anything that is NOT a good recipe.

### Rule Tweaks

RULES KEPT OFF PERMANENTLY (for now):
"players_interact_by_sharing_inventory": false,
"recipe_book_visit_changes_recipes": false,
"potion_delivery_regenerates_recipe": false,
"recipe_book_dynamic_read_dir": false