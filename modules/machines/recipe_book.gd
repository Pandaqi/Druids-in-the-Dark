class_name ModuleRecipeBook extends Node2D

var cur_index:int = 0
@onready var inventory_high : ModuleInventory = $InventoryHigh
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var inventory_low : ModuleInventory = $InventoryLow

func _ready():
	change_index(randi_range(0, GConfig.recipes_available.keys().size()))

func change_index(di:int) -> void:
	var num = GConfig.recipes_available.keys().size()
	cur_index = (cur_index + di + num) % num
	
	if di != 0:
		audio_player.play()
	
	var cur_recipe_name = GConfig.recipes_available.keys()[cur_index]
	var cur_recipe_comps : Array[String] = []
	for elem in GConfig.recipes_available[cur_recipe_name]:
		cur_recipe_comps.append(elem as String)
	
	set_visible_recipe([cur_recipe_name], cur_recipe_comps)

func set_visible_recipe(recipe_key:Array[String], recipe_components:Array[String]) -> void:
	inventory_high.set_content(recipe_components)
	inventory_low.set_content(recipe_key)
