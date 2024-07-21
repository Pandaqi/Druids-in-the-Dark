class_name ModuleElementDropper extends Node

var inventory : ModuleInventory

func activate(grid_mover:ModuleGridMover, inv:ModuleInventory):
	self.inventory = inv
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# can't drop here
	var machine = cell.get_machine_type()
	if machine != "bin": return
	
	for elem in inventory.get_content():
		cell.machine.add_content(elem)
	
	inventory.clear()
