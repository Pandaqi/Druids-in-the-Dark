class_name ModuleSpikeKiller extends Node

func activate(grid_mover:ModuleGridMover):
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	if cell.get_machine_type() != "spikes": return
	GDict.game_over.emit(false)
