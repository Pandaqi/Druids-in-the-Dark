class_name ModuleWildcardReader extends Node

var recipes : Recipes
var effects_tracker : ModuleEffectsTracker

func activate(r:Recipes, grid_mover:ModuleGridMover, et:ModuleEffectsTracker):
	self.recipes = r
	self.effects_tracker = et
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	if cell.get_machine_type() != "wildcard": return
	
	# if interaction is disabled, abort
	if GConfig.delivered_components_create_effects and effects_tracker.non_interact: 
		GDict.feedback.emit(cell.get_position(), "Non-Interact Curse!")
		return
	
	cell.machine.regenerate(recipes)
	GDict.feedback.emit(cell.get_position(), "Change!")
