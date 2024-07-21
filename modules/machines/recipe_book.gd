class_name ModuleRecipeBook extends Node2D

var cur_index:int = 0

func change_index(di:int, recipes:Recipes) -> void:
	var num = recipes.count()
	cur_index = (cur_index + di + num) % num
	
	var cur_recipe = recipes.dict.keys()[cur_index]
	set_visible_recipe(cur_recipe)

func set_visible_recipe(recipe:String) -> void:
	pass
	# @TODO
