class_name Recipes extends Node

var dict:Dictionary = {}
var progression:Progression
var wildcard:String = ""

func activate(prog:Progression):
	self.progression = prog

func regenerate():
	generate()
	generate_wildcard()

func generate():
	var potions := progression.get_available_potions()
	var elements := progression.get_available_elements()
	var max_length := progression.get_potion_max_length()
	
	var elements_needed := 0
	for i in range(potions.size()):
		var combo_length = i % max_length
		elements_needed += combo_length
	
	var num_per_element : int = ceil(float(elements_needed) / elements.size())
	var all_elements : Array[String] = []
	for elem in elements:
		for i in range(num_per_element):
			all_elements.append(elem)
	
	all_elements.shuffle()
	for i in range(potions.size()):
		var combo_length := i % max_length
		var slice_idx := all_elements.size() - combo_length - 1
		var combo := all_elements.slice(slice_idx)
		all_elements.resize(slice_idx + 1) # GDScript has no .splice like JS, so we need to manually forget about the elements we picked
		combo.sort() # nice consistent order that also matches inventory
		dict[potions[i]] = combo
	
	print(dict)
	GConfig.recipes_available = dict

func generate_wildcard():
	if not GConfig.wildcard_include: return
	
	var components := progression.get_available_elements()
	components.erase(wildcard) # don't allow re-picking the current one; has to CHANGE
	wildcard = components.pick_random()

func regenerate_potion(potion:String):
	var cur_length = dict[potion].size()
	var new_elems = progression.get_available_elements()
	new_elems.shuffle()
	dict[potion] = new_elems.slice(0, cur_length)

func is_wildcard(comp:String) -> bool:
	return wildcard == comp

func has_wildcard() -> bool:
	return wildcard != ""

func get_components_for(potion:String) -> Array[String]:
	var arr : Array[String] = []
	for elem in dict[potion]:
		arr.append(elem as String)
	return arr

func count() -> int:
	return dict.keys().size()

func on_order_delivered():
	progression.check_game_over()
	# @TODO: some bonus/reward?

func _on_progression_new_level() -> void:
	regenerate()

func select_potion_that_includes(potions:Array[String], comp:String) -> String:
	var suitable_potions : Array[String] = []
	for potion in potions:
		var comps = get_components_for(potion)
		if not comps.has(comp): continue
		suitable_potions.append(potion)
	if suitable_potions.size() <= 0: return potions.back()
	return suitable_potions.pick_random()
