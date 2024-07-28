class_name CellElement extends Node2D

var type : String
@onready var sprite : Sprite2D = $Sprite2D

func _ready():
	sprite.set_scale(GConfig.def_cell_element_scale * Vector2.ONE)
	if is_dynamic():
		add_to_group("DynamicElements")

func set_type(t:String):
	type = t
	sprite.set_frame(GDict.get_element_data(t).frame)
	
	if is_potion(): self.add_to_group("Potions")
	if is_component(): self.add_to_group("Components")
	if is_potion() or is_component(): self.add_to_group("PotionsAndComponents")

func is_potion() -> bool:
	return type in GDict.POTIONS

func is_component() -> bool:
	return type in GDict.ELEMENTS

func is_dynamic() -> bool:
	return type in GDict.MACHINES and GDict.MACHINES[type].dynamic
