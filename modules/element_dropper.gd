class_name ModuleElementDropper extends Node

var inventory : ModuleInventory

func activate(grid_mover:ModuleGridMover, inv:ModuleInventory):
	self.inventory = inv
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# can't drop here
	var machine = cell.get_machine_type()
	if machine != "garbage_bin": return
	if not inventory.has_content(): return
	
	for elem in inventory.get_content():
		cell.machine.add_content(elem)
	
	inventory.clear()
	GDict.feedback.emit(cell.get_position(), "In the bin!")
