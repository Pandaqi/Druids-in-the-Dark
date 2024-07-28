class_name ModuleGridMover extends Node

@onready var entity = get_parent()

var grid_pos : Vector2i
var map : Map
var busy : bool = false
var last_movement_direction : Vector2i

signal position_updated()
signal cell_entered()

func activate(m:Map, input:ModuleInput) -> void:
	self.map = m
	input.movement_vector_update.connect(move)

func update_position(new_pos:Vector2i, instant:bool = false) -> void:
	map.remove_player_from(grid_pos, entity)
	grid_pos = new_pos
	busy = true # @NOTE: must come before this signal, in case instant is true
	position_updated.emit(map.grid_pos_to_real_pos(grid_pos), instant)

func teleport(new_pos:Vector2i) -> void:
	if busy: return
	update_position(new_pos)

func move(vec:Vector2i) -> void:
	if vec.length() <= 0.03: return
	if busy: return
	
	var new_pos = map.get_pos_after_move(grid_pos, vec)
	var nothing_changed = new_pos.distance_squared_to(grid_pos) <= 0
	if nothing_changed: return
	
	last_movement_direction = vec
	update_position(new_pos)

func on_movement_done() -> void:
	map.add_player_to(grid_pos, entity)
	busy = false
	cell_entered.emit(map.get_cell_at(grid_pos))
