class_name ModuleOrderGiver extends Node

var inventory : ModuleInventory
var recipes : Recipes

func activate(grid_mover:ModuleGridMover, recipes:Recipes, inventory:ModuleInventory):
	self.inventory = inventory
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no order here, do nothing
	var machine = cell.get_machine_type()
	if machine != "order": return
	
	var potion = cell.machine.get_recipe()
	
	# check if we match
	var needed_components : Array[String] = recipes.get_components_for(potion)
	var our_components : Array[String] = inventory.get_content()
	var missing_components : int = 0
	for comp in needed_components:
		if not our_components.has(comp): missing_components += 1
		our_components.erase(comp)
	
	var is_match = our_components.size() <= 0 and missing_components <= 0
	if not is_match: return
	
	inventory.clear()
	cell.remove_machine()
	recipes.on_order_delivered()
