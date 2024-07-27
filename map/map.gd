class_name Map extends Node2D

const NB_OFFSETS = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

# we use a 1D array because GDScript doesn't support typed multidimensional arrays :/
var grid : Array[Cell] = []
var size : Vector2i = Vector2i(8,6)
@export var cell_scene : PackedScene

func activate(prog:Progression) -> void:
	GDict.map_shuffle.connect(on_map_shuffle_requested)
	var raw_size : Vector2 = (Vector2(GConfig.def_map_size) * GConfig.map_size_scalar[GInput.get_player_count()])
	size = raw_size.round()
	
	generate(prog)

func generate(prog:Progression) -> void:
	create_grid()
	cut_holes_in_grid()
	assign_order_cells(prog)
	assign_machines()
	visualize_grid()

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
	var num_holes : int = round( 0.5*sqrt(size.x * size.y) )
	var max_size : int = round( 0.33 * min(size.x, size.y) )
	
	for i in range(num_holes):
		var hole_size := Vector2i(randi_range(1,max_size), randi_range(1,max_size))
		var anchor := get_random_position()
		
		var cells_disabled : Array[Cell] = []
		for x in range(hole_size.x):
			for y in range(hole_size.y):
				var cur_pos := anchor + Vector2i(x,y)
				if out_of_bounds(cur_pos): continue
				
				var cur_cell := get_cell_at(cur_pos)
				cells_disabled.append(cur_cell)
				cur_cell.disabled = true
		
		var map_still_connected := is_map_fully_connected()
		if not map_still_connected:
			for cell in cells_disabled:
				cell.disabled = false

func is_map_fully_connected() -> bool:
	var num_enabled_cells = 0
	for cell in grid:
		if cell.disabled: continue
		num_enabled_cells += 1
	
	var cells_to_visit : Array[Cell] = [grid.front()]
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

func assign_order_cells(prog:Progression):
	var num_needed := prog.get_num_customers()
	var edge_cells := query_cells({ "edge": true, "num": num_needed })
	for cell in edge_cells:
		cell.add_machine("order")

# @TODO: you'll probably unlock more machines as you get further, which is when this should turn into a LOOP of "pick cell, set type"
func assign_machines():
	var num_machines_needed := 0
	var freq_scalar = GConfig.machine_frequency_scalar[GInput.get_player_count()]
	var freq_dict:Dictionary = {}
	for elem in GConfig.machines_included:
		var freq_bounds = GDict.MACHINES[elem].freq.duplicate(true)
		freq_bounds.min *= freq_scalar
		freq_bounds.max *= freq_scalar
		
		var freq = round(randf_range(freq_bounds.min, freq_bounds.max))
		freq_dict[elem] = freq
		num_machines_needed += freq
	
	var valid_cells := query_cells({ "edge": false, "empty": true, "num": num_machines_needed })
	
	for elem in freq_dict:
		for _i in range(freq_dict[elem]):
			var cell = valid_cells.pop_back()
			cell.add_machine(elem)
	
func visualize_grid():
	for cell in grid:
		cell.visualize()

func get_random_position() -> Vector2i:
	return Vector2i(randi_range(0, size.x), randi_range(0, size.y))

func pos_to_grid_id(pos:Vector2i) -> int:
	return pos.x + pos.y * size.x

func grid_id_to_pos(id:int) -> Vector2i:
	return Vector2i(id % size.x, floor(id / size.x))

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
		GDict.emit_signal("game_over", false)
		
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
	# @TODO: add any other types I might add later to this list of shufflable tiles
	var machine_cells : Array[Cell] = query_cells({ "machine": ["recipe_book", "garbage_bin"] })
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
	
	# @TODO: test if it's actually faster to ask only for a fixed num if we don't need a lot
	if "num" in params: 
		all_cells = grid.duplicate(false)
		all_cells.shuffle()
	
	for cell in all_cells:
		if cell.disabled: continue
		
		var suitable = true
		
		if "exclude" in params:
			suitable = (not params.exclude.has(cell)) and suitable
		
		if "edge" in params:
			suitable = (params.edge == cell.is_edge(size)) and suitable
		
		if "shadow" in params:
			suitable = (params.shadow == cell.shadow) and suitable
		
		if "empty" in params:
			suitable = (params.empty == cell.is_empty()) and suitable
		
		if "machine" in params:
			if not params.machine is Array: params.machine = [params.machine]
			var any_match = (params.machine[0] == "any" and cell.get_machine_type())
			var key_match = params.machine.has(cell.get_machine_type())
			suitable = (key_match or any_match) and suitable
		
		if not suitable: continue
		list.append(cell)
		
		if "num" in params and list.size() >= params.num: break
	
	return list
