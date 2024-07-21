class_name ModulePlayerShadow extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var entity = get_parent()

var range : int = 2

func activate():
	update_range(0)
	
	var tw = get_tree().create_tween()
	tw.set_loops()
	tw.tween_property(self, "scale", 0.925*Vector2.ONE, 0.5)
	tw.tween_property(self, "scale", 1.0*Vector2.ONE, 0.5)
	
	var tw2 = get_tree().create_tween()
	tw2.set_loops()
	tw2.tween_property(self, "modulate:a", 0.85, 0.763)
	tw2.tween_property(self, "modulate:a", 1.0, 0.763)

func update_range(dr:int):
	range = clamp(range + dr, 1, 5)
	sprite.set_scale((1.0 + 2*range)*Vector2.ONE)
