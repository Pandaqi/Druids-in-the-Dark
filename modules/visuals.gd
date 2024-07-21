class_name ModuleVisuals extends Node2D

@onready var sprite = $Sprite2D
@onready var entity = get_parent()
var moving : bool = false

signal movement_done()

func activate(grid_mover:ModuleGridMover):
	grid_mover.position_updated.connect(on_position_updated)
	movement_done.connect(grid_mover.on_movement_done)

# @TODO: tween this shit
func on_position_updated(real_pos:Vector2):
	var tw = get_tree().create_tween()
	tw.tween_property(entity, "position", real_pos, 0.2)
	tw.tween_callback(on_movement_done)
	moving = true

func on_movement_done():
	moving = false
	emit_signal("movement_done")
