extends Node

# this acts as a global signal bus, ONLY for the most crucial/large messages
# (everything else should be more private/tightly connected)
signal game_over(we_win:bool)
signal map_shuffle()
signal toggle_shadows_globally(in_shadow:bool)

const ELEMENTS : Dictionary = {
	"strawberry": { "frame": 0, "effect": "shadow_plus" },
	"banana": { "frame": 1, "effect": "shadow_min" },
	"orange": { "frame": 2, "effect": "speed_plus" },
	"pear": { "frame": 3, "effect": "speed_min" },
	"grapes": { "frame": 4, "effect": "non_interact" },
}

const POTIONS : Dictionary = {
	"regular": { "frame": 5 },
	"square": { "frame": 6 },
	"triangle": { "frame": 7 },
	"circle": { "frame": 8 },
	"heart": { "frame": 9 },
}

const MACHINES : Dictionary = {
	"recipe_book": { "frame": 10, "module_scene": "res://modules/machines/recipe_book.tscn", "dynamic": false, "freq": { "min": 1, "max": 2 } },
	"order": { "frame": 11, "module_scene": "res://modules/machines/order.tscn", "dynamic": false, },
	"garbage_bin": { "frame": 12, "module_scene": "res://modules/machines/garbage_bin.tscn", "dynamic": false, "freq": { "min": 1, "max": 3 } },
	"spikes": { "frame": 13, "module_scene": null, "dynamic": true, "freq": { "min": 0, "max": 5 } },
	"wildcard": { "frame": 14, "module_scene": "res://modules/machines/wildcard.tscn", "dynamic": false, "freq": { "min": 1, "max": 1 } },
	"teleport": { "frame": 15, "module_scene": null, "dynamic": false, "freq": { "min": 2, "max": 3 } }
}

const PLAYER_COLORS : Array[Color] = [
	Color(0.141, 0, 0),
	Color(0, 0.141, 0),
	Color(0, 0, 0.141),
	Color(0, 0.141, 0.141)
]

const TUTORIAL_ORDER : Array[String] = ["objective"]

# When the level first starts, it sets all variables to TUTORIALS.default
# Then, every new tutorial that's added (when going up levels), describes the _changes_ they make to what's already there
const TUTORIALS : Dictionary = {
	"default": {
		"changes":
		{
			"shadow_filter_based_on_effects": false,
			"disabled_cells_kill_you": false,
			
			"recipe_book_visit_changes_recipes": false,
			"potion_delivery_regenerates_recipe": false,
			"wildcard_include": false,
			
			"only_spawn_whats_wanted": true,
			"map_spawns_components": false,
			"map_spawns_potions": false,
			"mutate_elements_in_shadow": false,
			"remove_dynamic_elements_in_shadow": false,
			"potion_garbage_can_appear": false,
			"delivered_components_create_effects": false,
			
			"orders_are_timed": false,
			"customers_want_components": false,
			"customers_want_potions": false,
			"customer_visit_delays_timer": false,
			"order_only_visible_after_visit": false,
			"wrong_order_is_garbage": false,
			"wrong_order_moves_machines": false,
		}
	},
	
	"objective": {
		"frame": 1,
		"frame2": 2,
		"desc": "Pick up and deliver ingredients to where needed.\nDon't walk into holes!",
		"changes":
		{
			"disabled_cells_kill_you": true,
			"map_spawns_components": true,
			"customers_want_components": true,
			"wrong_order_is_garbage": true
		}
	}
}

func get_element_data(key:String):
	if key in MACHINES: return MACHINES[key]
	if key in POTIONS: return POTIONS[key]
	return ELEMENTS[key]

func get_random_mutation():
	# @NOTE: Mutation is supposed to be a negative/destructive effect
	# So I'm actually fine with picking from ALL options, even if they don't make sense
	var all_options = ELEMENTS.keys()
	if GConfig.map_spawns_potions or GConfig.customers_want_potions:
		all_options += POTIONS.keys()
	return all_options.pick_random()
