class_name ModuleRecipeReader extends Node

var recipes : Recipes
var effects_tracker : ModuleEffectsTracker
var grid_mover : ModuleGridMover

func activate(r:Recipes, gm:ModuleGridMover, et:ModuleEffectsTracker):
	self.recipes = r
	self.effects_tracker = et
	self.grid_mover = gm
	gm.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no recipe book here
	var machine = cell.get_machine_type()
	if machine != "recipe_book": return
	
	# if interaction is disabled, abort
	if GConfig.delivered_components_create_effects and effects_tracker.non_interact: return
	
	# other special effects based on interaction
	if GConfig.recipe_book_visit_changes_recipes:
		recipes.generate()
	
	# determine in which direction we should scroll the book
	var dir := +1
	if GConfig.recipe_book_dynamic_read_dir:
		var move_vec := grid_mover.last_movement_direction
		if move_vec.x < -0.03 or move_vec.y < -0.03:
			dir = -1
	
	cell.machine.change_index(dir, recipes)
	
	
