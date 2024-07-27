class_name ModuleWildcard extends Node2D

@onready var inventory : ModuleInventory = $Inventory

func regenerate(recipes:Recipes) -> void:
	recipes.generate_wildcard()
	set_visible_wildcard(recipes.wildcard)

func set_visible_wildcard(wc:String) -> void:
	inventory.set_content([wc])
