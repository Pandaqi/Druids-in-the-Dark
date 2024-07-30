class_name ModuleOrderGiver extends Node2D

var inventory : ModuleInventory
var recipes : Recipes
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var particles : CPUParticles2D = $DefaultParticles
@onready var entity = get_parent()

signal order_delivered(order:Array[String])

func activate(grid_mover:ModuleGridMover, r:Recipes, i:ModuleInventory):
	self.inventory = i
	self.recipes = r
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no order here, do nothing
	var machine = cell.get_machine_type()
	if machine != "order": return
	if not cell.machine.is_occupied(): return
	
	var order_elements = cell.machine.get_order()
	
	# destroy all potions into their components
	# so we just have a flat list of ingredients to match
	var needed_components : Array[String] = []
	var potion_inside_order = null
	for elem in order_elements:
		var is_potion = (elem in GDict.POTIONS)
		if is_potion:
			var potion_components : Array[String] = recipes.get_components_for(elem)
			needed_components += potion_components
			potion_inside_order = elem
		else:
			needed_components.append(elem)
	
	# check if we match EXACTLY
	var needed_components_copy := needed_components.duplicate(true)
	var our_components : Array[String] = inventory.get_content()

	# first handle raw matches
	for i in range(needed_components.size()-1,-1,-1):
		var comp = needed_components[i]
		if our_components.has(comp): 
			needed_components.remove_at(i)
			our_components.erase(comp)
	
	# for every non-wildcard ingredient REQUESTED, use a wildcard of ours
	if recipes.has_wildcard():
		for i in range(needed_components.size()-1,-1,-1):
			var comp = needed_components[i]
			if not recipes.is_wildcard(comp):
				if our_components.has(recipes.wildcard):
					needed_components.remove_at(i)
					our_components.erase(recipes.wildcard)
				else:
					break
		
		# for every wildcard ingredient REQUESTED, use any component of ours
		for i in range(needed_components.size()-1,-1,-1):
			var comp = needed_components[i]
			if recipes.is_wildcard(comp):
				our_components.pop_back()
				needed_components.remove_at(i)
	
	var is_match = our_components.size() <= 0 and needed_components.size() <= 0
	cell.machine.on_visit(is_match, inventory)
	if not is_match: return
	
	var time_fraction : float = cell.machine.get_time_fraction()
	var content := inventory.get_content()
	
	inventory.clear()
	cell.remove_machine()
	recipes.on_order_delivered(needed_components_copy, time_fraction)
	GDict.feedback.emit(entity.get_position(), "Delivered!")
	
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
	particles.play()
	
	# @NOTE: signal must come at the very end, otherwise we haven't removed order yet and should-end-game check fails
	order_delivered.emit(content)
	
	if GConfig.potion_delivery_regenerates_recipe and potion_inside_order:
		recipes.regenerate_potion(potion_inside_order)
