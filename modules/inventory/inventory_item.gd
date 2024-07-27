class_name InventoryItem extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var label : Label = $Label

func _ready():
	label.set_visible(false)

func set_frame(f:int):
	sprite.set_frame(f)
	# node.get_node("Sprite2DShadow").set_frame(f)

func set_number(n:int):
	label.set_visible(true)
	label.set_text(str(n))
