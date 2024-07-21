class_name Shadows extends Node2D

var map : Map
var players : Players
var shadowed_cells : Array[Cell]

func activate(map:Map, players:Players):
	self.players = players
	self.map = map

func on_player_moved(new_cell:Cell):
	var player_nodes := players.get_all()
	var new_shadowed_cells : Array[Cell] = []
	
	for cell in map.grid:
		
		var in_range_of_player = false
		for p in player_nodes:
			var range_squared = pow(p.player_shadow.range, 2)
			var dist_squared = p.grid_mover.grid_pos.distance_squared_to(cell.pos)
			if dist_squared <= range_squared:
				in_range_of_player = true
				break
		
		if not in_range_of_player: 
			if cell.shadow: cell.set_shadow(false)
			continue
		
		if not cell.shadow: cell.set_shadow(true)
		new_shadowed_cells.append(cell)
	
	shadowed_cells = new_shadowed_cells
