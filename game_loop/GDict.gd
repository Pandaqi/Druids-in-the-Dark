extends Node

signal game_over(we_win:bool)
signal map_shuffle()

const ELEMENTS = {
	"strawberry": { "frame": 0 },
	"banana": { "frame": 1 },
	"orange": { "frame": 2 },
	"pear": { "frame": 3 },
	"grapes": { "frame": 4 },
}

const POTIONS = {
	"regular": { "frame": 5 },
	"square": { "frame": 6 },
	"triangle": { "frame": 7 },
	"circle": { "frame": 8 },
	"heart": { "frame": 9 },
}

const MACHINES = {
	"recipe_book": { "frame": 10, "module_scene": preload("res://modules/machines/recipe_book.tscn") },
	"order": { "frame": 11, "module_scene": preload("res://modules/machines/order.tscn") },
	"garbage_bin": { "frame": 12, "module_scene": preload("res://modules/machines/garbage_bin.tscn") }
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
