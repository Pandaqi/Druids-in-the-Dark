extends Node

@onready var timer : Timer = $Timer
@onready var progression : Progression = get_parent()
var map : Map
var recipes : Recipes

var wanted_components : Array[String] = []
var wanted_potions : Array[String] = []

func activate(m:Map, r:Recipes):
	self.map = m
	self.recipes = r
	
	var prog_tick = GConfig.def_prog_tick * GConfig.prog_tick_scalar[GInput.get_player_count()]
	timer.wait_time = prog_tick
	timer.timeout.connect(on_timer_timeout)
	timer.start()

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
	
	var num_potions := get_tree().get_nodes_in_group("PotionsAndComponents").size()
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
	
	var potion_cells = map.query_cells({ "empty": true, "shadow": false, "machine_neighbor_forbidden": "order", "num": 1 })
	
	var need_no_more_customers := order_cells_free.size() <= 0 or customer_diff <= 0
	var need_no_more_potions := potion_cells.size() <= 0 or potion_diff <= 0
	
	# we basically pick the one with the biggest DIFFERENCE to their target number
	# but if we're below minimum, we always add 1 to make up
	# and if we're at maximum, we always forbid
	var create_potion : bool = (num_potions < potion_bounds.min) or potion_diff > customer_diff or need_no_more_customers
	if need_no_more_potions: create_potion = false
	if map.is_full(): create_potion = false
	
	var create_customer : bool = (num_customers < customer_bounds.min) or customer_diff >= potion_diff or need_no_more_potions
	if need_no_more_customers: create_customer = false
	
	var all_potions := progression.get_available_potions()
	var random_potion : String = all_potions.pick_random()
	
	var all_components := progression.get_available_elements()
	var random_component : String = all_components.pick_random()
	
	if progression.boosted_component:
		var regular_prob_potion = 1.0 / all_potions.size()
		if randf() <= GConfig.boosted_component_factor * regular_prob_potion:
			random_potion = recipes.select_potion_that_includes(all_potions, progression.boosted_component)
		
		var regular_prob_comp = 1.0 / all_components.size()
		if randf() <= GConfig.boosted_component_factor * regular_prob_comp:
			random_component = progression.boosted_component
	
	if create_potion:
		var elem = null
		
		var spawn_potion := GConfig.map_spawns_potions
		var spawn_component := GConfig.map_spawns_components
		var prefer_comp_if_both := randf() <= GConfig.map_spawn_component_over_potion_prob
		
		if spawn_potion: elem = random_potion
		if spawn_component and (prefer_comp_if_both or not spawn_potion): elem = random_component
		
		if GConfig.only_spawn_whats_wanted:
			if (elem == random_potion) and wanted_potions.size() > 0:
				wanted_potions.shuffle()
				elem = wanted_potions.pop_back()
			
			if (elem == random_component) and wanted_components.size() > 0:
				wanted_components.shuffle()
				elem = wanted_components.pop_back()
		
		if elem:
			potion_cells.pop_back().add_element(elem)
	
	if create_customer:
		var elem = null
		
		if GConfig.customers_want_potions and randf() <= GConfig.customer_want_potion_prob:
			elem = random_potion
			wanted_potions.append(elem)
		
		if GConfig.customers_want_components and (randf() <= GConfig.customer_want_component_prob or !elem):
			elem = random_component
			wanted_components.append(elem)
		
		if elem:
			order_cells_free.pop_back().machine.add_recipe(elem)
