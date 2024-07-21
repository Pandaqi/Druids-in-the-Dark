class_name Players extends Node2D

@export var player_scene : PackedScene
var starting_cells : Array[Cell]
var num_players : int
var players : Array[Player]

func activate(map:Map, recipes:Recipes, shadows:Shadows) -> void:
	GInput.create_debugging_players()
	num_players = GInput.get_player_count()
	starting_cells = map.query_cells({ "empty": true, "num": num_players })
	place_players(map, recipes, shadows)

func get_all() -> Array[Player]:
	return players

func place_players(map:Map, recipes:Recipes, shadows:Shadows):
	players = []
	for i in range(num_players):
		place_player(i, map, recipes, shadows)

func place_player(player_num:int, map:Map, recipes:Recipes, shadows:Shadows):
	var p : Player = player_scene.instantiate()
	players.append(p)
	add_child(p)
	
	p.activate(player_num, map, recipes)
	
	p.grid_mover.cell_entered.connect(shadows.on_player_moved)
	
	var pos = starting_cells[player_num].pos
	p.grid_mover.update_position(pos)
