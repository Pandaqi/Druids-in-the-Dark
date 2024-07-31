class_name Map extends Node2D

const NB_OFFSETS = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

# we use a 1D array because GDScript doesn't support typed multidimensional arrays :/
var grid : Array[Cell] = []
var size : Vector2i = Vector2i(8,6)
var progression : Progression
var players : Players
var recipes : Recipes
@export var cell_scene : PackedScene

func activate(prog:Progression, p:Players, r: Recipes) -> void:
	self.progression = prog
	self.players = p
	self.recipes = r
	GDict.map_shuffle.connect(on_map_shuffle_requested)

func regenerate() -> void:
	# delete old
	for cell in grid:
		cell.kill()
	
	# determine proper size
	var raw_size : Vector2 = Vector2(GConfig.def_map_size)
	raw_size *= GConfig.map_size_scalar[GInput.get_player_count()]
	
	var progression_growth = clamp(pow(GConfig.map_size_growth_per_level, progression.level), 1.0, GConfig.map_size_growth_max)
	raw_size *= progression_growth
	
	size = raw_size.round()
	
	recipes.regenerate()
	
	# do the whole dance
	create_grid()
	cut_holes_in_grid()
	assign_order_cells()
	assign_machines()
	assign_planter_cells()
	visualize_grid()
	
	# now tell players where they can stand
	players.reset()

func create_grid():
	grid = []
	grid.resize(size.x*size.y)
	
	for x in range(size.x):
		for y in range(size.y):
			var cur_pos = Vector2i(x,y)
			var c : Cell = cell_scene.instantiate()
			c.pos = cur_pos
			
			var id = pos_to_grid_id(cur_pos)
			grid[id] = c
			add_child(c)

func cut_holes_in_grid():
	var num_holes : int = round( 0.66 * sqrt(size.x * size.y) )
	var max_size : int = round( 0.35 * min(size.x, size.y) )
	var holes_created := 0
	
	while holes_created < num_holes:
		var hole_size := Vector2i(randi_range(1,max_size), randi_range(1,max_size))
		
		var anchor := get_random_position()
		
		var cells_disabled : Array[Cell] = []
		for x in range(hole_size.x):
			for y in range(hole_size.y):
				var cur_pos := anchor + Vector2i(x,y)
				if out_of_bounds(cur_pos): continue
				
				var cur_cell := get_cell_at(cur_pos)
				if cur_cell.disabled: continue
				
				cells_disabled.append(cur_cell)
				cur_cell.disabled = true
		
		var barely_changed_anything = cells_disabled.size() <= 0
		if barely_changed_anything:
			continue
		
		var map_still_connected := is_map_fully_connected()
		if not map_still_connected:
			for cell in cells_disabled:
				cell.disabled = false
			continue
		
		holes_created += 1

func is_map_fully_connected() -> bool:
	var num_enabled_cells = 0
	var random_enabled_cell : Cell = null
	for cell in grid:
		if cell.disabled: continue
		num_enabled_cells += 1
		random_enabled_cell = cell
	
	var cells_to_visit : Array[Cell] = [random_enabled_cell]
	var cells_visited : Array[Cell] = []
	while cells_to_visit.size() > 0:
		var cell = cells_to_visit.pop_back()
		cells_visited.append(cell)
		
		var nbs = get_neighbors_of(cell)
		for nb in nbs:
			if nb.disabled: continue
			if cells_visited.has(nb): continue
			if cells_to_visit.has(nb): continue
			cells_to_visit.append(nb)
	
	return cells_visited.size() >= num_enabled_cells

func get_neighbors_of(cell:Cell) -> Array[Cell]:
	var arr: Array[Cell] = []
	for NB_OFF in NB_OFFSETS:
		var new_pos : Vector2i = cell.pos + NB_OFF
		if out_of_bounds(new_pos): continue
		arr.append(get_cell_at(new_pos))
	return arr

func assign_order_cells() -> void:
	var num_needed := progression.get_num_customers()
	var edge_cells := query_cells({ "edge": true, "num": num_needed })
	for cell in edge_cells:
		cell.add_machine("order")

func assign_planter_cells() -> void:
	var num_needed := progression.planter_cells.size()
	if num_needed <= 0: return
	
	var valid_cells := query_cells({ "empty": true, "num": num_needed })
	for i in range(valid_cells.size()):
		var cell := valid_cells[i]
		cell.add_machine("planter")
		cell.machine.set_type(progression.planter_cells[i])

func assign_machines() -> void:
	var num_machines_needed := 0
	var freq_scalar = GConfig.machine_frequency_scalar[GInput.get_player_count()]
	var freq_dict:Dictionary = {}
	for elem in GConfig.machines_included:
		var data = GDict.MACHINES[elem]
		if data.dynamic: continue
		
		var freq_bounds = data.freq.duplicate(true)
		freq_bounds.min *= freq_scalar
		freq_bounds.max *= freq_scalar
		
		var freq = round(randf_range(freq_bounds.min, freq_bounds.max))
		freq_dict[elem] = freq
		num_machines_needed += freq
	
	var valid_cells := query_cells({ "edge": false, "empty": true, "num": num_machines_needed })
	
	for elem in freq_dict:
		
		var num_needed : int = freq_dict[elem]
		for _i in range(num_needed):
			var cell = valid_cells.pop_back()
			cell.add_machine(elem)

			# @TODO: I should've probably just initialized stuff in general here, also the recipe book
			if elem == "wildcard": 
				cell.machine.set_visible_wildcard(recipes.wildcard)
	
func visualize_grid() -> void:
	for cell in grid:
		cell.visualize()

func get_random_position() -> Vector2i:
	return Vector2i(randi_range(0, size.x), randi_range(0, size.y))

func pos_to_grid_id(pos:Vector2i) -> int:
	return pos.x + pos.y * size.x

func grid_id_to_pos(id:int) -> Vector2i:
	return Vector2i(id % size.x, floor(id / float(size.x)))

func grid_pos_to_real_pos(grid_pos:Vector2i) -> Vector2:
	return GConfig.cell_size * Vector2(grid_pos)

func real_pos_to_grid_pos(real_pos:Vector2) -> Vector2i:
	return Vector2i(floor(real_pos.x / GConfig.cell_size), floor(real_pos.y / GConfig.cell_size))

func get_cell_at(grid_pos:Vector2i) -> Cell:
	return grid[pos_to_grid_id(grid_pos)]

func is_valid_cell(grid_pos:Vector2i, for_movement := false) -> bool:
	if out_of_bounds(grid_pos): return false
	if is_hole_at(grid_pos, for_movement): return false
	return true

func out_of_bounds(grid_pos:Vector2i) -> bool:
	return grid_pos.x < 0 or grid_pos.x >= size.x or grid_pos.y < 0 or grid_pos.y >= size.y

func is_hole_at(grid_pos:Vector2i, for_movement := false) -> bool:
	if GConfig.disabled_cells_kill_you and for_movement: return false
	return get_cell_at(grid_pos).disabled

func get_pos_after_move(grid_pos:Vector2i, vec:Vector2i) -> Vector2i:
	var new_pos = grid_pos + vec
	if not is_valid_cell(new_pos, true): return grid_pos
	return new_pos

func add_player_to(grid_pos:Vector2i, p:Player) -> void:
	if GConfig.disabled_cells_kill_you and get_cell_at(grid_pos).disabled:
		GDict.feedback.emit(p.get_position(), "Oh no!")
		GDict.game_over.emit(false)
		
	get_cell_at(grid_pos).add_player(p)

func remove_player_from(grid_pos:Vector2i, p:Player) -> void:
	get_cell_at(grid_pos).remove_player(p)

func get_bounds() -> Rect2:
	var cs = GConfig.cell_size
	return Rect2(
		-0.5 * Vector2(cs, cs),
		size * cs
	)

func on_map_shuffle_requested():
	var machine_cells : Array[Cell] = query_cells({ "machine": ["recipe_book", "garbage_bin", "spikes", "planter"] })
	var allowed_cells : Array[Cell] = query_cells({ "shadow": false, "empty": true, "num": machine_cells.size() })
	
	for cell in machine_cells:
		if allowed_cells.size() <= 0: break
		
		var type = cell.get_machine_type()
		cell.remove_machine()
		
		var new_cell : Cell = allowed_cells.pop_back()
		new_cell.add_machine(type)

func query_cells(params:Dictionary) -> Array[Cell]:
	var list : Array[Cell] = []
	
	var all_cells := grid
	var fixed_num := "num" in params
	
	if fixed_num: 
		all_cells = grid.duplicate(false)
		all_cells.shuffle()
	
	for cell in all_cells:
		if fixed_num and list.size() >= params.num: break
		if cell.disabled: continue
		
		var suitable = true
		
		if "exclude" in params:
			if not params.exclude is Array: params.exclude = [params.exclude]
			suitable = (not params.exclude.has(cell)) and suitable
		
		if "edge" in params:
			suitable = (params.edge == cell.is_edge(size)) and suitable
		
		if "shadow" in params:
			suitable = (params.shadow == cell.shadow) and suitable
		
		if "empty" in params:
			suitable = (params.empty == cell.is_empty()) and suitable
		
		if "machine_neighbor_forbidden" in params:
			var nbs = get_neighbors_of(cell)
			var is_forbidden := false
			for nb in nbs:
				if nb.get_machine_type() != params.machine_neighbor_forbidden: continue
				is_forbidden = true
				break
			suitable = (not is_forbidden) and suitable
		
		if "machine" in params:
			if not params.machine is Array: params.machine = [params.machine]
			var any_match = (params.machine[0] == "any" and cell.get_machine_type())
			var key_match = params.machine.has(cell.get_machine_type())
			suitable = (key_match or any_match) and suitable
		
		if not suitable: continue
		list.append(cell)
	
	return list

func _on_progression_new_level() -> void:
	regenerate()

func count_empty_cells() -> int:
	var num := 0
	for cell in grid:
		if not cell.is_empty(): continue
		num += 1
	return num

func count_total_cells() -> int:
	return grid.size()

func is_full() -> bool:
	return count_empty_cells() / float(count_total_cells()) <= GConfig.map_percentage_required_empty
	
