class_name ModuleVisuals extends Node2D

@onready var sprite = $Sprite2D
@onready var entity = get_parent()
var moving : bool = false
var movement_duration := GConfig.def_move_tween_duration

signal movement_done()

func activate(grid_mover:ModuleGridMover, effects_tracker:ModuleEffectsTracker):
	grid_mover.position_updated.connect(on_position_updated)
	effects_tracker.effects_changed.connect(on_effects_changed)
	movement_done.connect(grid_mover.on_movement_done)

func on_position_updated(real_pos:Vector2, instant:bool):
	moving = true
	
	if instant:
		entity.set_position(real_pos)
		on_movement_done()
		return
	
	var tw = get_tree().create_tween()
	tw.tween_property(entity, "position", real_pos, movement_duration)
	tw.tween_callback(on_movement_done)

func on_movement_done():
	moving = false
	emit_signal("movement_done")

# @TODO: clamp between reasonable values
func change_speed(factor:float):
	movement_duration *= factor

func on_effects_changed(eff:Array[String]) -> void:
	if not GConfig.delivered_components_create_effects: return
	
	for elem in eff:
		var data = GDict.get_element_data(elem)
		if data.effect == "speed_plus": change_speed(2.0)
		elif data.effect == "speed_min": change_speed(0.5)
