class_name Progression extends Node

var map : Map

var level := 0

var all_elements_order : Array[String]
var num_elements_order : Array[int]
var all_potions_order : Array[String]
var num_potions_order : Array[int]

var potion_max_length_order : Array[int]
var num_customers_order : Array[int]

const MAX_LEVELS = 20

@onready var timer : Timer = $Timer

func activate(map:Map):
	self.map = map
	
	generate()
	
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
	num_customers_order = fill_order_list(range(2,7))

func fill_order_list(num_range) -> Array[int]:
	var arr : Array[int] = []
	
	# create a staggered list with random skips before it jumps up again
	for i in num_range:
		var num_skip = randi_range(1,5)
		for a in range(num_skip):
			arr.append(i as int)
	
	# if space remains, fill it up with the final value
	while arr.size() < MAX_LEVELS:
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

func on_timer_timeout() -> void:
	# @TODO: these need to be dynamically determined, scaled with player count, etcetera
	var potion_bounds := { "min": 1, "max": 3 }
	var customer_bounds := { "min": 1, "max": 3 }
	
	var num_potions := get_tree().get_nodes_in_group("Potions").size()
	var num_customers := get_tree().get_nodes_in_group("Customers").size()
	
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
	
	if create_potion:
		potion_cells.pop_back().add_element(random_potion)
	
	if create_customer:
		order_cells_free.pop_back().machine.add_recipe(random_potion)
		
func check_game_over():
	var no_orders_left = map.query_cells({ "machine": "order" }).size() <= 0
	if no_orders_left:
		GDict.emit_signal("game_over", true)

func on_game_over(we_win:bool):
	print("Game Over!")
	print("We win?", we_win)
