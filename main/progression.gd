class_name Progression extends Node

var map : Map

var level := 0

var all_elements_order : Array[String]
var num_elements_order : Array[int]
var all_potions_order : Array[String]
var num_potions_order : Array[int]

var wanted_components : Array[String] = []
var wanted_potions : Array[String] = []

var potion_max_length_order : Array[int]
var num_customers_order : Array[int]

@onready var timer : Timer = $Timer

func activate(map:Map):
	self.map = map
	
	generate()
	
	var prog_tick = GConfig.def_prog_tick * GConfig.prog_tick_scalar[GInput.get_player_count()]
	timer.wait_time = prog_tick
	timer.timeout.connect(on_timer_timeout)
	timer.start()
	
	GDict.game_over.connect(on_game_over)

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

# @NOTE: "potion" just means any collectible (potion/component); this is a nasty consequence of changing the game's rules all the time through development
func on_timer_timeout() -> void:
	var potion_bounds := GConfig.prog_def_potion_bounds.duplicate(true) 
	var customer_bounds := GConfig.prog_def_customer_bounds.duplicate(true)
	var potion_bounds_scalar = GConfig.prog_potion_bounds_scalar[GInput.get_player_count()]
	var customer_bounds_scalar = GConfig.prog_customer_bounds_scalar[GInput.get_player_count()]
	
	potion_bounds.min *= potion_bounds_scalar
	potion_bounds.max *= potion_bounds_scalar
	customer_bounds.min *= customer_bounds_scalar
	customer_bounds.max *= customer_bounds_scalar
	
	var num_potions := get_tree().get_nodes_in_group("Potions").size()
	var num_customers := get_tree().get_nodes_in_group("Customers").size()
	
	print("#potions", num_potions)
	print("#customers", num_customers)
	
	var potion_diff : int = potion_bounds.max - num_potions
	var customer_diff : int = customer_bounds.max - num_customers
	
	var order_cells := map.query_cells({ "machine": "order" })
	var order_cells_free = []
	for cell in order_cells:
		if cell.machine.is_occupied(): continue
		order_cells_free.append(cell)
	order_cells_free.shuffle()
	
	var potion_cells = map.query_cells({ "empty": true, "shadow": false, "num": 1 })
	
	var need_no_more_customers := order_cells_free.size() <= 0 or customer_diff <= 0
	var need_no_more_potions := potion_cells.size() <= 0 or potion_diff <= 0
	
	# we basically pick the one with the biggest DIFFERENCE to their target number
	# but if we're below minimum, we always add 1 to make up
	# and if we're at maximum, we always forbid
	var create_potion : bool = (num_potions < potion_bounds.min) or potion_diff > customer_diff or need_no_more_customers
	if need_no_more_potions: create_potion = false
	
	var create_customer : bool = (num_customers < customer_bounds.min) or customer_diff >= potion_diff or need_no_more_potions
	if need_no_more_customers: create_customer = false
	
	var random_potion = get_available_potions().pick_random()
	var random_component = get_available_elements().pick_random()
	
	if create_potion:
		var elem = null
		
		if GConfig.map_spawns_potions and randf() <= GConfig.map_spawn_potion_prob:
			elem = random_potion
		
		if GConfig.map_spawns_components and (randf() <= GConfig.map_spawn_component_prob or !elem):
			elem = random_component
		
		if GConfig.only_spawn_whats_wanted:
			if (elem == random_potion) and wanted_potions.size() > 0:
				wanted_potions.shuffle()
				elem = wanted_potions.pop_back()
			
			if (elem == random_component) and wanted_components.size() > 0:
				wanted_components.shuffle()
				elem = wanted_components.pop_back()
		
		potion_cells.pop_back().add_element(elem)
	
	if create_customer:
		var elem = null
		
		if GConfig.customers_want_potions and randf() <= GConfig.customer_want_potion_prob:
			elem = random_potion
			wanted_potions.append(elem)
		
		if GConfig.customers_want_components and (randf() <= GConfig.customer_want_component_prob or !elem):
			elem = random_component
			wanted_components.append(elem)
		
		order_cells_free.pop_back().machine.add_recipe(elem)
		
func check_game_over():
	var no_orders_left = map.query_cells({ "machine": "order" }).size() <= 0
	if no_orders_left:
		GDict.emit_signal("game_over", true)

func on_game_over(we_win:bool):
	print("Game Over!")
	print("We win?", we_win)
