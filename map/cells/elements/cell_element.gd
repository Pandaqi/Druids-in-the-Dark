class_name CellElement extends Node2D

var type : String
@onready var sprite : Sprite2D = $Sprite2D
@onready var anim_player : AnimationPlayer = $AnimationPlayer

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

func play_tween() -> void:
	if GConfig.debug_disable_tweens: return
	var tw = get_tree().create_tween()
	var cur_scale = self.scale
	tw.tween_property(self, "scale", 1.2*cur_scale, 0.1)
	tw.tween_property(self, "scale", cur_scale, 0.2)

func play_loop_tween():
	anim_player.play("loop_tween")

func stop_loop_tween():
	anim_player.stop()
