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
	"recipe_book": { "frame": 10, "module_scene": "res://modules/machines/recipe_book.tscn", "dynamic": false, "freq": { "min": 1, "max": 1 } },
	"order": { "frame": 11, "module_scene": "res://modules/machines/order.tscn", "dynamic": false },
	"garbage_bin": { "frame": 12, "module_scene": "res://modules/machines/garbage_bin.tscn", "dynamic": false, "freq": { "min": 1, "max": 3 } },
	"spikes": { "frame": 13, "module_scene": null, "dynamic": true, "freq": { "min": 0, "max": 5 } },
	"wildcard": { "frame": 14, "module_scene": "res://modules/machines/wildcard.tscn", "dynamic": false, "freq": { "min": 1, "max": 1 } },
	"teleport": { "frame": 15, "module_scene": null, "dynamic": false, "freq": { "min": 2, "max": 3 } },
	"planter": { "frame": 16, "module_scene": "res://modules/machines/planter.tscn", "dynamic": false }
}

const PLAYER_COLORS : Array[Color] = [
	Color(0.141, 0, 0),
	Color(0, 0.141, 0),
	Color(0, 0, 0.141),
	Color(0.141, 0, 0.141)
]

# @NOTE: It's basically a three-tiered system (basic mechanics, medium mechanics, advanced mechanics)
# With breaks between the tiers to prevent overwhelming the player / provide some sort of "intermediary boss"
const TUTORIAL_ORDER : Array[String] = [
	"objective", 
	"orders_core", "potions_core", "shadow_mechanic_filter", "machine_recipe_book", "machine_garbage_bin", "",
	"orders_medium", "potions_medium", "shadow_mechanic_mutate", "machine_wildcard", "machine_spikes", "",
	"orders_advanced", "potions_advanced", "shadow_mechanic_delivery", "machine_teleport", "machine_garbage_bin_advanced", "", ""
]

# When the level first starts, it sets all variables to TUTORIALS.default
# Then, every new tutorial that's added (when going up levels), describes the _changes_ they make to what's already there
const TUTORIALS : Dictionary = {
	"default": {
		"changes":
		{
			"shadow_filter_based_on_effects": false,
			"garbage_bin_content_is_permanent": false,
			"disabled_cells_kill_you": false,
			"players_interact_by_sharing_inventory": false,
			
			"recipe_book_dynamic_read_dir": false,
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
		"desc": "[b]Pick up[/b] and [b]deliver[/b] ingredients to where needed. (Delivering the [b]wrong[/b] thing [b]empties[/b] your backpack.)\n[b]Don't[/b] walk into holes!",
		"changes":
		{
			"disabled_cells_kill_you": true,
			"map_spawns_components": true,
			"customers_want_components": true,
			"wrong_order_is_garbage": true
		}
	},
	
	"orders_core": {
		"frame": 3,
		"desc": "Orders have a [b]time limit[/b]! You can extend it by visiting the cell.",
		"changes":
		{
			"orders_are_timed": true,
			"customer_visit_delays_timer": true
		}
	},
	
	"orders_medium": {
		"frame": 8,
		"desc": "From now on, you must [b]visit[/b] an order before you can see what they want!",
		"changes":
		{
			"order_only_visible_after_visit": true,
		}
	},
	
	"orders_advanced": {
		"frame": 13,
		"desc": "Delivering the [b]wrong order[/b] will randomly move around parts of the level.",
		"changes":
		{
			"wrong_order_moves_machines": true,
		}
	},
	
	"potions_core": {
		"frame": 4,
		"desc": "Finished [b]potions[/b] can appear. Walk through them to [b]break[/b] them into their individual components.",
		"changes":
		{
			"map_spawns_components": false,
			"map_spawns_potions": true,
		}
	},
	
	"potions_medium": {
		"frame": 9,
		"desc": "Customers can also request [b]potions[/b]. Deliver the right set of ingredients (order irrelevant) to satisfy them.",
		"changes":
		{
			"map_spawns_components": false,
			"customers_want_potions": true,
		}
	},
	
	"potions_advanced": {
		"frame": 14,
		"desc": "When [b]breaking[/b] a potion, it can randomly spawn garbage elements you (probably) don't need.",
		"changes":
		{
			"customers_want_components": false,
			"potion_garbage_can_appear": true,
		}
	},
	
	"shadow_mechanic_delivery": {
		"frame": 15,
		"desc": "Whenever you [b]deliver[/b] an order, its ingredients become permanent powerups or curses to you.\nDiscover how each ingredient changes you while playing!",
		"changes": 
		{
			"delivered_components_create_effects": true
		},
	},
	
	"shadow_mechanic_mutate": {
		"frame": 10,
		"desc": "The [b]longer[/b] a component is kept in [b]shadow[/b], the more likely it is to [b]mutate[/b]: become anything else.",
		"changes": 
		{
			"mutate_elements_in_shadow": true
		},
	},
	
	"shadow_mechanic_filter": {
		"frame": 5,
		"desc": "Whenever you [b]deliver[/b] an order, its ingredients will [b]stay visible[/b] through your shadow (until you deliver the next order).",
		"changes": 
		{
			"map_spawns_components": true, # merely turned off when potions introduced
			"shadow_filter_based_on_effects": true
		},
	},
	
	"machine_recipe_book": {
		"frame": 6,
		"desc": "You get a [b]Recipe Book[/b]! It shows 1 recipe at a time. Visit to show the next recipe.",
		"changes": {},
		"machines": ["recipe_book"]
	},
	
	"machine_garbage_bin": {
		"frame": 7,
		"desc": "You get a [b]Garbage Bin[/b]! Visit to throw away your inventory.\n (You can't do so by giving the wrong order anymore.)",
		"changes": 
		{
			"wrong_order_is_garbage": false
		},
		"machines": ["garbage_bin"]
	},
	
	"machine_garbage_bin_advanced": {
		"frame": 17,
		"desc": "The component that appears [b]most often[/b] in the [b]Garbage Bin[/b], has consequences for the next level:\nAll players receive its effect, orders are more likely to contain it, and you get a cell where it automatically grows.",
		"changes": 
		{
			"garbage_bin_content_is_permanent": true
		},
	},
	
	"machine_wildcard": {
		"frame": 11,
		"desc": "One component is a [b]Wildcard[/b]: it can stand for any type you want.\nVisit the Wildcard to change it (randomly).",
		"changes": 
		{
			"wildcard_include": true
		},
		"machines": ["wildcard"]
	},
	
	"machine_spikes": {
		"frame": 12,
		"desc": "[b]Spikes[/b] can appear! They kill you instantly.\nIf you keep them in shadow for a while, though, they automatically go away.",
		"changes": 
		{
			"remove_dynamic_elements_in_shadow": true
		},
		"machines": ["spikes"]
	},
	
	"machine_teleport": {
		"frame": 16,
		"desc": "You get [b]Teleport[/b] cells! Step on one to instantly move to another Teleport cell (picked randomly).",
		"changes": {},
		"machines": ["teleport"]
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
