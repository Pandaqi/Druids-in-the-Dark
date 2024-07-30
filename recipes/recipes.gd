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
	
	dict = {}
	
	var elements_needed := 0
	for i in range(potions.size()):
		var combo_length = (i % max_length) + 1
		elements_needed += combo_length
		dict[potions[i]] = []
	
	var num_per_element : int = ceil(float(elements_needed) / elements.size())
	var all_elements : Array[String] = []
	
	# ensure they all appear at least once; otherwise, it's random
	for elem in elements:
		all_elements.append(elem)
	
	while all_elements.size() < elements_needed:
		all_elements.append(elements.pick_random())
	
	# To ENSURE all elements are used (no matter potion count/size)
	# we actually keep looping through the potions until we've exhausted them all
	# however, any surplus ones are added to existing potions already
	all_elements.shuffle()
	var counter := 0
	while all_elements.size() > 0:
		var potion_num := counter % potions.size()
		var combo_length : int = min( (counter % max_length) + 1, all_elements.size() )
		var combo := all_elements.slice(0, combo_length)
		combo.sort() # nice consistent order that also matches inventory
		
		# GDScript has no .splice like JS, so we need to manually forget about the elements we picked
		for i in range(combo_length):
			all_elements.pop_front()

		dict[potions[potion_num]] += combo
		counter += 1
	
	print("Recipe Dict")
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

func on_order_delivered(comps:Array[String], time_left:float):
	# time_left is fraction between 0 and 1; less means you were slower, so fewer points
	var score := comps.size() * 10 * time_left
	GDict.scored.emit(score)
	
	# this should come LAST of course, otherwise we go game over before finishing the rest!
	progression.check_game_over()

func select_potion_that_includes(potions:Array[String], comp:String) -> String:
	var suitable_potions : Array[String] = []
	for potion in potions:
		var comps = get_components_for(potion)
		if not comps.has(comp): continue
		suitable_potions.append(potion)
	if suitable_potions.size() <= 0: return potions.back()
	return suitable_potions.pick_random()
