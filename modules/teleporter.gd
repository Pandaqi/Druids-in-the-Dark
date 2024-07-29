class_name ModuleTeleporter extends Node

var map : Map
var grid_mover : ModuleGridMover

func activate(gm:ModuleGridMover, m:Map):
	self.map = m
	self.grid_mover = gm
	gm.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	if cell.get_machine_type() != "teleport": return
	
	var valid_cells : Array[Cell] = map.query_cells({ "exclude": cell, "machine": "teleport", "num": 1 })
	if valid_cells.size() <= 0: return
	
	# @NOTE: to ensure all other signals for entering this specific cell are done firing and we get no mess
	await get_tree().process_frame
	
	var new_cell : Cell = valid_cells.pop_back()
	grid_mover.teleport(new_cell.pos)
	GDict.feedback.emit(cell.get_position(), "Teleport!")
