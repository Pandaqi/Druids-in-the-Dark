class_name Progression extends Node

var map : Map
var tutorial : Tutorial
var countdown : Countdown
var shadows : Shadows

var level := 0

var all_elements_order : Array[String]
var num_elements_order : Array[int]
var all_potions_order : Array[String]
var num_potions_order : Array[int]

var potion_max_length_order : Array[int]
var num_customers_order : Array[int]

@onready var potion_order_balancer = $PotionOrderBalancer
@onready var dynamic_cell_spawner = $DynamicCellSpawner

func activate(map:Map, tutorial:Tutorial, countdown:Countdown, shadows:Shadows):
	self.map = map
	self.tutorial = tutorial
	self.countdown = countdown
	self.shadows = shadows
	
	GDict.game_over.connect(on_game_over)
	tutorial.load_default_properties()
	
	generate()
	
	potion_order_balancer.activate(map)
	dynamic_cell_spawner.activate(map)

func generate():
	# determine the order in which elements will be added/revealed
	all_elements_order = []
	for key in GDict.ELEMENTS.keys():
		all_elements_order.append(key as String)
	
	all_potions_order = []
	for key in GDict.POTIONS.keys():
		all_potions_order.append(key as String)
	
	all_elements_order.shuffle()
	all_potions_order.shuffle()
	
	# determine the exact number of them in each round
	num_elements_order = fill_order_list(range(2,all_elements_order.size()))
	num_potions_order = fill_order_list(range(2,all_potions_order.size()))
	potion_max_length_order = fill_order_list(range(2,6))
	
	var num_customers_bounds = GConfig.prog_def_num_total_customers_bounds.duplicate(true)
	var num_customers_scalar = GConfig.prog_num_total_customers_scalar[GInput.get_player_count()]
	num_customers_bounds.min = round(num_customers_bounds.min * num_customers_scalar)
	num_customers_bounds.max = round(num_customers_bounds.max * num_customers_scalar)
	num_customers_order = fill_order_list(range(num_customers_bounds.min, num_customers_bounds.max))

func fill_order_list(num_range) -> Array[int]:
	var arr : Array[int] = []
	
	# create a staggered list with random skips before it jumps up again
	for i in num_range:
		var num_skip = randi_range(1,5)
		for a in range(num_skip):
			arr.append(i as int)
	
	# if space remains, fill it up with the final value
	while arr.size() < GConfig.max_levels_per_run:
		arr.append(num_range.back() as int)

	return arr

func get_available_elements() -> Array[String]:
	return all_elements_order.slice(0, num_elements_order[level])

func get_available_potions() -> Array[String]:
	return all_potions_order.slice(0, num_potions_order[level])

func get_num_customers() -> int:
	return num_customers_order[level]

func get_potion_max_length() -> int:
	return potion_max_length_order[level]

func check_game_over():
	var no_orders_left = map.query_cells({ "machine": "order" }).size() <= 0
	if no_orders_left:
		GDict.emit_signal("game_over", true)

func on_game_over(we_win:bool):
	print("Game Over!")
	print("We win?", we_win)
	shadows.set_global_shadow(false)
	end_level()

func start_level() -> void:
	get_tree().paused = true
	
	shadows.set_global_shadow(false)
	
	tutorial.load_properties_of(level)
	tutorial.display(level)
	await tutorial.dismissed
	
	countdown.activate()
	await countdown.is_done
	
	shadows.set_global_shadow(true)
	
	get_tree().paused = false

func end_level() -> void:
	level += 1
