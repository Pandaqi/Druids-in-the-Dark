class_name ModuleRecipeBook extends Node2D

var cur_index:int = 0
@onready var inventory_high : ModuleInventory = $InventoryHigh
@onready var inventory_low : ModuleInventory = $InventoryLow

func change_index(di:int, recipes:Recipes) -> void:
	var num = recipes.count()
	cur_index = (cur_index + di + num) % num
	
	var cur_recipe = recipes.dict.keys()[cur_index]
	set_visible_recipe([cur_recipe], recipes.get_components_for(cur_recipe))

func set_visible_recipe(recipe_key:Array[String], recipe_components:Array[String]) -> void:
	inventory_high.set_content(recipe_components)
	inventory_low.set_content(recipe_key)
