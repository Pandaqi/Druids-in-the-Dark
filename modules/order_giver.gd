class_name ModuleOrderGiver extends Node

var inventory : ModuleInventory
var recipes : Recipes

func activate(grid_mover:ModuleGridMover, recipes:Recipes, inventory:ModuleInventory):
	self.inventory = inventory
	self.recipes = recipes
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
	var our_components : Array[String] = inventory.get_content()
	var missing_components : int = 0
	for comp in needed_components:
		if not our_components.has(comp): missing_components += 1
		our_components.erase(comp)
	
	var is_match = our_components.size() <= 0 and missing_components <= 0
	cell.machine.on_visit(is_match, inventory)
	if not is_match: 
		return
	
	inventory.clear()
	cell.remove_machine()
	recipes.on_order_delivered()
	
	if GConfig.potion_delivery_regenerates_recipe and potion_inside_order:
		recipes.regenerate_potion(potion_inside_order)
