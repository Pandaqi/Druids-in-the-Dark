class_name ModuleVisuals extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var entity = get_parent()
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var movement_particles : CPUParticles2D = $MovementParticles

var moving : bool = false
var movement_duration := GConfig.def_move_tween_duration

signal movement_done()

func activate(player_num: int, grid_mover:ModuleGridMover, effects_tracker:ModuleEffectsTracker):
	sprite.set_frame(4 + player_num)
	
	grid_mover.position_updated.connect(on_position_updated)
	effects_tracker.effects_changed.connect(on_effects_changed)
	movement_done.connect(grid_mover.on_movement_done)
	
	movement_particles.set_emitting(false)

func on_position_updated(real_pos:Vector2, instant:bool):
	moving = true
	
	movement_particles.set_visible(true)
	movement_particles.set_emitting(true)
	
	if instant:
		entity.set_position(real_pos)
		on_movement_done()
		return
	
	
	audio_player.pitch_scale = randf_range(0.9, 1.0)
	audio_player.play()
	
	var tw := get_tree().create_tween()
	tw.tween_property(entity, "position", real_pos, movement_duration)
	tw.tween_callback(on_movement_done)
	
	var tw_rot := get_tree().create_tween()
	var wiggle_rot := 0.05*PI
	tw_rot.tween_property(self, "rotation", -wiggle_rot, 0.25*movement_duration)
	tw_rot.tween_property(self, "rotation", wiggle_rot, 0.5*movement_duration)
	tw_rot.tween_property(self, "rotation", 0, 0.25*movement_duration)

func on_movement_done():
	moving = false
	movement_done.emit()
	movement_particles.set_emitting(false)

func change_speed(factor:float):
	var base_val := GConfig.def_move_tween_duration
	movement_duration = clamp(factor, 0.25*base_val, 4.0*base_val)

func on_effects_changed(eff:Array[String]) -> void:
	if not GConfig.delivered_components_create_effects: return
	
	for elem in eff:
		var data = GDict.get_element_data(elem)
		if data.effect == "speed_plus": change_speed(2.0)
		elif data.effect == "speed_min": change_speed(0.5)

func reset():
	movement_particles.restart()
	movement_particles.set_emitting(false)
	movement_particles.set_visible(false)
