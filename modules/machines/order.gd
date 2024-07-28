class_name ModuleOrder extends Node2D

@onready var timer : Timer = $Timer
@onready var inventory : ModuleInventory = $Inventory
@onready var cell_element : CellElement = get_parent()
@onready var cell : Cell = get_parent().get_parent()
var tween_occupied : Tween
var visited := false

func _ready():
	
	if GConfig.order_only_visible_after_visit:
		inventory.set_visible(false)

func add_recipe(r:String) -> void:
	self.add_to_group("Customers")
	inventory.add_content(r)
	start_timer()

func get_order() -> Array[String]:
	return inventory.get_content()

func is_occupied() -> bool:
	return inventory.has_content()

func start_timer() -> void:
	if GConfig.orders_are_timed:
		var order_dur_scalar = GConfig.order_duration_scalar[GInput.get_player_count()]
		timer.wait_time = randf_range(GConfig.def_order_duration.min, GConfig.def_order_duration.max) * order_dur_scalar
		timer.timeout.connect(on_timer_timeout)
		timer.start()
	
	tween_occupied = get_tree().create_tween()
	var dur = 0.75
	tween_occupied.tween_property(cell_element, "scale", 0.7*Vector2.ONE, dur)
	tween_occupied.tween_property(cell_element, "scale", 1.0*Vector2.ONE, dur)
	tween_occupied.set_loops(1000)

func change_timer(dt:float) -> void:
	if not GConfig.orders_are_timed: return
	
	var new_time_left = timer.time_left + dt
	timer.stop()
	timer.start(new_time_left)

func _physics_process(_dt:float) -> void:
	update_progress_bar()

func update_progress_bar() -> void:
	if not GConfig.orders_are_timed: return
	if not is_occupied(): return
	
	var timer_left = timer.time_left / timer.wait_time
	cell.floor_sprite.set_scale(timer_left * Vector2.ONE)

func finish() -> void:
	tween_occupied.kill()
	inventory.clear()
	remove_from_group("Customers")
	cell.floor_sprite.set_scale(Vector2.ONE)

func on_timer_timeout() -> void:
	finish()
	GDict.game_over.emit(false)

func on_visit(is_match:bool, visitor_inventory:ModuleInventory) -> void:
	visited = true
	
	if GConfig.order_only_visible_after_visit:
		inventory.set_visible(true)
	
	if GConfig.customer_visit_delays_timer and not is_match:
		var avg_timer : float = (GConfig.def_order_duration.min + GConfig.def_order_duration.max)
		var delay = 0.5 * avg_timer * GConfig.customer_timer_delay_scalar
		cell.machine.change_timer(delay)
	
	if GConfig.wrong_order_is_garbage and not is_match:
		visitor_inventory.clear()
	
	if GConfig.wrong_order_moves_machines and not is_match:
		GDict.map_shuffle.emit()
	
