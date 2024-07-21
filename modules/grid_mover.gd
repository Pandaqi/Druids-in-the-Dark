class_name ModuleGridMover extends Node

@onready var entity = get_parent()

var grid_pos : Vector2i
var map : Map
var busy : bool = false

signal position_updated()
signal cell_entered()

func activate(map:Map, input:ModuleInput):
	self.map = map
	input.movement_vector_update.connect(move)

func update_position(new_pos:Vector2i):
	map.remove_player_from(grid_pos, entity)
	grid_pos = new_pos
	emit_signal("position_updated", map.grid_pos_to_real_pos(grid_pos))
	busy = true

func move(vec:Vector2i):
	if vec.length() <= 0.03: return
	if busy: return
	
	var new_pos = map.get_pos_after_move(grid_pos, vec)
	var nothing_changed = new_pos.distance_squared_to(grid_pos) <= 0
	if nothing_changed: return
	
	update_position(new_pos)

func on_movement_done():
	map.add_player_to(grid_pos, entity)
	busy = false
	emit_signal("cell_entered", map.get_cell_at(grid_pos))
	
	
	
