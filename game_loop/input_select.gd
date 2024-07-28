extends Control

@onready var nodes = [
	$MarginContainer/HBoxContainer/PlayerSelect1,
	$MarginContainer/HBoxContainer/PlayerSelect2,
	$MarginContainer/HBoxContainer/PlayerSelect3,
	$MarginContainer/HBoxContainer/PlayerSelect4,
]

func _ready():
	for i in range(nodes.size()):
		nodes[i].init(i)
	refresh_nodes()

func _input(ev):
	var res_add = GInput.check_new_player(ev)
	if not res_add.failed:
		refresh_nodes()
	
	var res_remove = GInput.check_remove_player(ev)
	if not res_remove.failed:
		refresh_nodes()

func refresh_nodes():
	for i in range(4):
		var node = nodes[i]
		var should_activate = i < GInput.get_player_count()
		var next_node_up = i == GInput.get_player_count()
		if should_activate: node.activate()
		else: node.deactivate(next_node_up)
		
