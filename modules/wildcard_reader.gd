class_name ModuleWildcardReader extends Node

var recipes : Recipes
var effects_tracker : ModuleEffectsTracker

func activate(recipes:Recipes, grid_mover:ModuleGridMover, effects_tracker:ModuleEffectsTracker):
	self.recipes = recipes
	self.effects_tracker = effects_tracker
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	if cell.get_machine_type() != "wildcard": return
	
	# if interaction is disabled, abort
	if GConfig.delivered_components_create_effects and effects_tracker.non_interact: return
	
	cell.machine.regenerate(recipes)
