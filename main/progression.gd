class_name Progression extends Node

var map : Map
var tutorial : Tutorial
var countdown : Countdown
var shadows : Shadows
var game_over : GameOver
var players : Players

var level := 0
var score := 0.0

var all_elements_order : Array[String]
var num_elements_order : Array[int]
var all_potions_order : Array[String]
var num_potions_order : Array[int]

var potion_max_length_order : Array[int]
var num_customers_order : Array[int]

var planter_cells : Array[String] = []
var boosted_component : String = ""

@onready var potion_order_balancer = $PotionOrderBalancer
@onready var dynamic_cell_spawner = $DynamicCellSpawner
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

signal new_level

func activate(m:Map, t:Tutorial, c:Countdown, s:Shadows, g:GameOver, p:Players, recipes:Recipes):
	self.map = m
	self.tutorial = t
	self.countdown = c
	self.shadows = s
	self.game_over = g
	self.players = p
	
	GDict.game_over.connect(on_game_over)
	GDict.scored.connect(on_scored)

	level = 0
	if OS.is_debug_build() and GConfig.debug_starting_level > 0:
		level = GConfig.debug_starting_level
	
	tutorial.load_cumulative_properties_until(level)
	generate()
	
	potion_order_balancer.activate(map, recipes)
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
		var num_skip = randi_range(GConfig.prog_skip_bounds.min, GConfig.prog_skip_bounds.max)
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
		GDict.game_over.emit(true)

func on_game_over(we_win:bool):
	end_level(we_win)

func start_level() -> void:
	# @NOTE: this must come before sending signals or doing anything else, otherwise it obviously generates the new map with the OLD properties (of previous level)
	tutorial.load_properties_of(level)
	
	new_level.emit()
	
	get_tree().paused = true
	shadows.set_global_shadow(false)
	
	tutorial.display(level)
	await tutorial.dismissed
	
	countdown.appear()
	await countdown.is_done
	
	audio_player.play()
	shadows.set_global_shadow(true)
	get_tree().paused = false

func end_level(we_win:bool) -> void:
	shadows.set_global_shadow(false)
	make_garbage_bin_permanent()
	if we_win: level += 1
	game_over.appear(we_win, level)
	audio_player.play()
	get_tree().paused = true

func make_garbage_bin_permanent():
	if not GConfig.garbage_bin_content_is_permanent: return
	
	# gather the entire contents of all bins
	var bins = map.query_cells({ "machine": "garbage_bin" })
	var freq_dict:Dictionary = {}
	for bin in bins:
		var content = bin.machine.get_content()
		for elem in content:
			if not (elem in freq_dict): freq_dict[elem] = 0
			freq_dict[elem] += 1
	
	# find the highest
	var highest_num : int = -100
	var highest_key : String = ""
	for key in freq_dict:
		if freq_dict[key] <= highest_num: continue
		highest_key = key
		highest_num = freq_dict[key]
	
	if highest_num <= 0 or not highest_key: return
	
	# make it permanent
	# effects to all, permanent planter cell, component more likely next round
	for p in players.get_all():
		p.effects_tracker.on_order_delivered([highest_key])
	add_planter_cell(highest_key)
	boosted_component = highest_key
	
func add_planter_cell(key:String) -> void:
	if planter_cells.size() >= GConfig.prog_max_planter_cells: return
	planter_cells.append(key)

func on_scored(pts:float) -> void:
	score = clamp(score + pts, 0, 999)
