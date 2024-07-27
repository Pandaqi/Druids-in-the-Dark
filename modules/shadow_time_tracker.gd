class_name ModuleShadowTimeTracker extends Node

@export var cell : Cell
@onready var timer : Timer
var time_in_shadow : float = 0.0
var last_time_change : float = 0.0

func activate():
	timer.wait_time = GConfig.mutate_check_tick
	timer.timeout.connect(on_timer_timeout)
	cell.shadow_changed.connect(on_shadow_changed)

func get_cur_time_diff() -> float:
	var cur_time = Time.get_ticks_msec()
	return cur_time - last_time_change

func get_total_time_in_shadow() -> float:
	return time_in_shadow + get_cur_time_diff()

func on_shadow_changed(in_shadow:bool) -> void:
	if in_shadow: 
		timer.start()
	else:
		timer.stop()
		time_in_shadow += get_cur_time_diff()
	
	last_time_change = Time.get_ticks_msec()

func reset():
	time_in_shadow = 0.0
	last_time_change = Time.get_ticks_msec()

func on_timer_timeout() -> void:
	check_if_should_mutate()
	check_if_should_disappear()

func check_if_should_mutate() -> void:
	if not GConfig.mutate_elements_in_shadow: return
	
	var can_mutate = get_total_time_in_shadow() >= GConfig.mutate_min_time
	if not can_mutate: return
	if randf() > GConfig.mutate_prob: return
	
	reset()
	cell.mutate()

func check_if_should_disappear() -> void:
	if not GConfig.remove_dynamic_elements_in_shadow: return
	
	var elem = cell.get_element()
	if not elem or not GDict.get_element_data(elem).dynamic: return
	
	var should_disappear = get_total_time_in_shadow() >= GConfig.remove_dynamic_min_time
	if not should_disappear: return
	
	reset()
	cell.remove_element()
	
