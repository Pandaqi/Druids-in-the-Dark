class_name Recipes extends Node

var dict:Dictionary = {}
var progression:Progression

func activate(progression:Progression):
	self.progression = progression
	generate(progression)

func generate(progression:Progression):
	var potions := progression.get_available_potions()
	var elements := progression.get_available_elements()
	var max_length := progression.get_potion_max_length()
	
	var elements_needed := 0
	for i in range(potions.size()):
		var combo_length = i % max_length
		elements_needed += combo_length
	
	var num_per_element = ceil(float(elements_needed) / elements.size())
	var all_elements = []
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

func get_components_for(potion:String) -> Array[String]:
	return dict[potion].duplicate(false)

func count() -> int:
	return dict.keys().size()

func on_order_delivered():
	progression.check_game_over()
	# @TODO: some bonus/reward?
