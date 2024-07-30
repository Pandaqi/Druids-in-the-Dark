class_name ModuleWildcard extends Node2D

@onready var inventory : ModuleInventory = $Inventory
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D

func regenerate(recipes:Recipes) -> void:
	audio_player.play()
	recipes.generate_wildcard()
	set_visible_wildcard(recipes.wildcard)

func set_visible_wildcard(wc:String) -> void:
	inventory.set_content([wc])
