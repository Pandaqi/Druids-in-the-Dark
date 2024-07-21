class_name CellElement extends Node2D

var type : String
@onready var sprite : Sprite2D = $Sprite2D

func set_type(t:String):
	type = t
	sprite.set_frame(GDict.get_element_data(t).frame)
	
	if is_potion(): self.add_to_group("Potions")

func is_potion():
	return type in GDict.POTIONS

func is_component():
	return type in GDict.ELEMENTS

# @TODO
