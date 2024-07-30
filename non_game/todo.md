


### Polishing / Future To-Do

* Add some more particles and animations
  * A simple tween-animation when a machine is used (this is a default function on the cell, so it can be called by the machine modules)
* Some way to GAIN more lives? (Especially in later levels, you might want that certainty.)
* Wait with counting up #potions (in Progression) until they're actually introduced in the game?
* Lean more into the "Holes" => breakable cells (after visiting X times), cells that are on/off half the time, etcetera
  * Yeah, I have some GREAT ideas for better holes + movement stuff at the END of the devlog
* Settings + Rebindable controls
* A permanent icon to display if your non-interactive or not => Maybe smaller feedback elements to reveal what ingredients do (as bonuses/curses once delivered)
* On multiplayer, one player can do the "back-and-forth" between order cells to keep extending their timer.
  * THis isn't too bad, because it still turns everything in that area into shadow (you can't see how much time left, or what they even wanted)
  * And because this only works if they're really close and that person isn't needed elsewhere, so MEH.

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
