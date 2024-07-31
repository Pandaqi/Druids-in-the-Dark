class_name ModuleTeleporter extends Node

var map : Map
var grid_mover : ModuleGridMover
var prev_cell : Cell

func activate(gm:ModuleGridMover, m:Map):
	self.map = m
	self.grid_mover = gm
	gm.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	var came_from_teleport = prev_cell and prev_cell.get_machine_type() == "teleport"
	prev_cell = cell
	if came_from_teleport: return # to prevent instantly teleporting away again
	
	if cell.get_machine_type() != "teleport": return
	
	var valid_cells : Array[Cell] = map.query_cells({ "exclude": cell, "machine": "teleport", "num": 1 })
	if valid_cells.size() <= 0: return
	
	# @NOTE: to ensure all other signals for entering this specific cell are done firing and we get no mess
	grid_mover.lock()
	await get_tree().process_frame
	
	var new_cell : Cell = valid_cells.pop_back()
	grid_mover.teleport(new_cell.pos)
	GDict.feedback.emit(cell.get_position(), "Teleport!")
