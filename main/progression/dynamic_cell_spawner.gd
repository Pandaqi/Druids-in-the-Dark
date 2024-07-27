extends Node

@onready var timer : Timer = $Timer
var map : Map

func activate(map:Map) -> void:
	self.map = map
	
	var tick_dur = GConfig.def_dynamic_spawner_tick * GConfig.dynamic_spawner_tick_scalar[GInput.get_player_count()]
	timer.wait_time = tick_dur
	timer.timeout.connect(on_timer_timeout)
	timer.start()

func on_timer_timeout() -> void:
	var max = GDict.MACHINES["spikes"].freq.max * GConfig.dynamic_spawner_freq_scalar[GInput.get_player_count()]
	var num = get_tree().get_nodes_in_group("DynamicElements").size()
	if num >= max: return
	
	var valid_cells = map.query_cells({ "empty": true, "shadow": false, "num": 1 })
	if valid_cells.size() <= 0: return
	
	var cell_picked = valid_cells.pop_back()
	cell_picked.add_element("spikes")
