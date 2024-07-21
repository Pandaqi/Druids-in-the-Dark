class_name ModuleElementGrabber extends Node

var inventory : ModuleInventory

func activate(grid_mover:ModuleGridMover, inv:ModuleInventory):
	self.inventory = inv
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no element here, do nothing
	var elem = cell.get_element()
	if not elem: return
	
	inventory.add_content(elem.type)
	cell.remove_element()
