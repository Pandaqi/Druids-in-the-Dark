extends Node

@onready var timer : Timer = $Timer
var map : Map

func activate(m:Map) -> void:
	self.map = m
	timer.timeout.connect(on_timer_timeout)

func on_level_ended():
	timer.stop()

func restart():
	var tick_dur = GConfig.def_dynamic_spawner_tick * GConfig.dynamic_spawner_tick_scalar[GInput.get_player_count()]
	timer.wait_time = tick_dur
	timer.start()

func on_timer_timeout() -> void:
	# @TODO: needs changing for better check if I ever have multiple possible dynamic machines or something; fine now
	if not GConfig.machines_included.has("spikes"): return
	
	var max_objects = GDict.MACHINES["spikes"].freq.max * GConfig.dynamic_spawner_freq_scalar[GInput.get_player_count()]
	var num_objects = get_tree().get_nodes_in_group("DynamicElements").size()
	if num_objects >= max_objects: return
	
	if map.is_full(): return
	
	var valid_cells = map.query_cells({ "empty": true, "shadow": false, "num": 1 })
	if valid_cells.size() <= 0: return
	
	var cell_picked = valid_cells.pop_back()
	cell_picked.add_machine("spikes")
