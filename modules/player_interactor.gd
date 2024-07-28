class_name ModulePlayerInteractor extends Node

var effects_tracker : ModuleEffectsTracker

func activate(grid_mover:ModuleGridMover, et:ModuleEffectsTracker):
	self.effects_tracker = et
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# if we're alone, nothing to interact with
	var players_here : Array[Player] = cell.get_players()
	if players_here.size() <= 1: return
	
	# if interaction is disabled, abort
	if not GConfig.players_interact_by_sharing_inventory: return
	if GConfig.delivered_components_create_effects and effects_tracker.non_interact: return
	
	# figure out who should get all the elements
	var best_player : Player = null
	var biggest_inventory : int = 0
	var all_content : Array[String] = []
	for p in players_here:
		var inv : ModuleInventory = p.inventory
		var inv_size = inv.count()
		all_content = all_content + inv.get_content()
		
		if inv_size <= biggest_inventory: continue
		
		biggest_inventory = inv_size
		best_player = p
	
	# actually hand those over, clear the rest
	for p in players_here:
		var inv : ModuleInventory = p.inventory
		if p == best_player: inv.clear()
		else: inv.set_content(all_content)
	
	
