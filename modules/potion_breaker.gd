class_name ModulePotionBreaker extends Node

var map : Map
var recipes : Recipes

func activate(map:Map, recipes:Recipes, grid_mover:ModuleGridMover):
	self.map = map
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no potion here, do nothing
	var elem = cell.get_element()
	if not elem: return
	if not elem.is_potion(): return
	
	# disassemble into the right elements
	var components = recipes.get_components_for(elem)
	
	# distribute over valid cells
	# @TODO: write this dynamic query function
	var cells_allowed : Array[Cell] = map.query_cells({
		"shadow": true,
		"empty": true
	})
	cells_allowed.shuffle()
	var cells_chosen = cells_allowed.slice(0, components.size())
	for i in range(cells_chosen.size()):
		cells_chosen[i].add_element(components[i])
	
	# remove the actual potion
	cell.remove_element()
