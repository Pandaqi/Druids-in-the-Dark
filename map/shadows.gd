class_name Shadows extends Node2D

var map : Map
var players : Players
var shadowed_cells : Array[Cell]
var global_shadow := false

func activate(m:Map, p:Players):
	self.players = p
	self.map = m

func on_player_moved(_new_cell:Cell = null):
	if not players: return
	
	var player_nodes := players.get_all()
	var new_shadowed_cells : Array[Cell] = []
	
	for cell in map.grid:
		
		var should_have_shadow := false
		
		for p in player_nodes:
			var in_range_of_player = false
			var range_squared = pow(p.player_shadow.get_range(), 2)
			var dist_squared = p.grid_mover.grid_pos.distance_squared_to(cell.pos)
			if dist_squared <= range_squared:
				in_range_of_player = true
			
			var is_filtered_out = p.effects_tracker.has_component( cell.get_element_type() ) and GConfig.shadow_filter_based_on_effects
			if in_range_of_player and not is_filtered_out:
				should_have_shadow = true
				break
		
		# a hard override for when the entire game should not have shadows
		if not global_shadow:
			should_have_shadow = false
		
		cell.set_shadow(should_have_shadow)
		if should_have_shadow:
			new_shadowed_cells.append(cell)
	
	shadowed_cells = new_shadowed_cells

func set_global_shadow(val:bool) -> void:
	global_shadow = val
	GDict.toggle_shadows_globally.emit(global_shadow)
	on_player_moved()
