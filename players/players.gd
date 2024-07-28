class_name Players extends Node2D

@export var player_scene : PackedScene
var starting_cells : Array[Cell]
var num_players : int
var players : Array[Player]
var map : Map

func _ready():
	GInput.create_debugging_players()

func activate(m:Map, recipes:Recipes, shadows:Shadows) -> void:
	self.map = m
	num_players = GInput.get_player_count()
	create_players(recipes, shadows)

func get_all() -> Array[Player]:
	return players

func create_players(recipes:Recipes, shadows:Shadows):
	players = []
	for i in range(num_players):
		create_player(i, recipes, shadows)

func create_player(player_num:int, recipes:Recipes, shadows:Shadows):
	var p : Player = player_scene.instantiate()
	players.append(p)
	add_child(p)
	
	p.activate(player_num, map, recipes)
	p.grid_mover.cell_entered.connect(shadows.on_player_moved)

func reset():
	# move all players to new cells
	starting_cells = map.query_cells({ "empty": true, "num": num_players })
	for i in range(num_players):
		var pos = starting_cells[i].pos
		players[i].grid_mover.update_position(pos, true)
	
	# Don't reset anything else?? Actually makes sense ...
	
