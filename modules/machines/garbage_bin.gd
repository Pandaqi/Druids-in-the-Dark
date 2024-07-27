class_name ModuleGarbageBin extends Node2D

@onready var inventory : ModuleInventory = $Inventory

func add_content(r:String):
	inventory.max_size = 100
	inventory.group_by_type = true
	inventory.add_content(r)
