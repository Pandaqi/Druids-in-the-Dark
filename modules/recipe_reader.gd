class_name ModuleRecipeReader extends Node

var recipes : Recipes

func activate(recipes:Recipes, grid_mover:ModuleGridMover):
	self.recipes = recipes
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no recipe book here
	var machine = cell.get_machine_type()
	if machine != "recipe_book": return
	
	# @TODO: perhaps change in different dirs (+1/-1) based on "last movement direction" saved on grid_mover?
	cell.machine.change_index(+1, recipes)
