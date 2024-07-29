extends Control

@onready var nodes : Array[PlayerSelect] = [
	$MarginContainer/HBoxContainer/PlayerSelect1,
	$MarginContainer/HBoxContainer/PlayerSelect2,
	$MarginContainer/HBoxContainer/PlayerSelect3,
	$MarginContainer/HBoxContainer/PlayerSelect4,
]

func _ready():
	for i in range(nodes.size()):
		nodes[i].init(i)
		nodes[i].readied_up.connect(on_player_readied)
	refresh_nodes()

func on_player_readied() -> void:
	var num_needed := GInput.get_player_count()
	var num_ready := 0
	for node in nodes:
		if node.is_ready: num_ready += 1
	
	var should_start := num_ready >= num_needed
	if not should_start: return
	
	get_tree().change_scene_to_packed(preload("res://game_loop/main.tscn"))

func _input(ev):
	var res_add = GInput.check_new_player(ev)
	if not res_add.failed:
		refresh_nodes()
	
	var res_remove = GInput.check_remove_player(ev)
	if not res_remove.failed:
		refresh_nodes()

func refresh_nodes() -> void:
	for i in range(4):
		var node := nodes[i]
		var should_activate := i < GInput.get_player_count()
		var next_node_up := i == GInput.get_player_count()
		if should_activate: node.activate()
		else: node.deactivate(next_node_up)
		
