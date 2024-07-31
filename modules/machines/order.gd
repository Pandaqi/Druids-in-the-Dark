class_name ModuleOrder extends Node2D

@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var timer : Timer = $Timer
@onready var inventory : ModuleInventory = $Inventory
@onready var cell : Cell = get_parent().get_parent()
var tween_occupied : Tween
var visited := false

func _ready():
	if GConfig.order_only_visible_after_visit:
		inventory.set_visible(false)

func add_recipe(r:String) -> void:
	add_to_group("Customers")
	inventory.add_content(r)
	start_timer()
	audio_player.play()

func remove_recipe():
	if tween_occupied: tween_occupied.kill()
	cell.machine_node.stop_loop_tween()
	inventory.clear()
	remove_from_group("Customers")
	cell.floor_sprite.set_scale(Vector2.ONE)

func get_order() -> Array[String]:
	return inventory.get_content()

func is_occupied() -> bool:
	return inventory.has_content()

func start_timer() -> void:
	if GConfig.orders_are_timed:
		var order_dur_scalar : float = GConfig.order_duration_scalar[GInput.get_player_count()]
		var order_dur_prog_scalar : float = clamp(pow(GConfig.order_duration_prog_scalar_per_level, GConfig.cur_level), 1.0, GConfig.order_duration_prog_scalar_max)
		timer.wait_time = randf_range(GConfig.def_order_duration.min, GConfig.def_order_duration.max) * order_dur_scalar * order_dur_prog_scalar
		timer.timeout.connect(on_timer_timeout)
		timer.start()
	
	cell.machine_node.play_loop_tween()
	
	# @DEBUGGING
	#tween_occupied = get_tree().create_tween()
	#var dur = 0.75
	#var cell_element = get_parent()
	#tween_occupied.tween_property(cell_element, "scale", 0.7*Vector2.ONE, dur)
	#tween_occupied.tween_property(cell_element, "scale", 1.0*Vector2.ONE, dur)
	#tween_occupied.set_loops(1000)

func change_timer(dt:float) -> void:
	if not GConfig.orders_are_timed: return
	
	var new_time_left = timer.time_left + dt
	timer.stop()
	timer.start(new_time_left)

func get_time_fraction() -> float:
	if not GConfig.orders_are_timed: return 1.0
	return timer.time_left / timer.wait_time

func _physics_process(_dt:float) -> void:
	update_progress_bar()

func update_progress_bar() -> void:
	if not GConfig.orders_are_timed: return
	if not is_occupied(): return
	
	var timer_left = get_time_fraction()
	cell.floor_sprite.set_scale(timer_left * Vector2.ONE)

func finish() -> void:
	remove_recipe()

func on_timer_timeout() -> void:
	finish()
	cell.floor_sprite.set_scale(Vector2.ZERO) # to help player realize this is why they lost
	GDict.feedback.emit(cell.get_position(), "Too Late!")
	GDict.game_over.emit(false)

func on_visit(is_match:bool, visitor_inventory:ModuleInventory) -> void:
	visited = true
	
	if not is_match and inventory.visible and visitor_inventory.has_content():
		GDict.feedback.emit(cell.get_position(), "Wrong Order!")
	
	if GConfig.order_only_visible_after_visit:
		GDict.feedback.emit(cell.get_position(), "Your order, please?")
		inventory.set_visible(true)
	
	if GConfig.customer_visit_delays_timer and not is_match:
		var avg_timer : float = (GConfig.def_order_duration.min + GConfig.def_order_duration.max)
		var delay = 0.5 * avg_timer * GConfig.customer_timer_delay_scalar
		GDict.feedback.emit(cell.get_position(), "Extra Time!")
		cell.machine.change_timer(delay)
	
	if GConfig.wrong_order_is_garbage and not is_match:
		visitor_inventory.clear()
	
	if GConfig.wrong_order_moves_machines and not is_match and visitor_inventory.has_content():
		GDict.map_shuffle.emit()
	
