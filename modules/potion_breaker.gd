class_name ModulePotionBreaker extends Node2D

var map : Map
var recipes : Recipes
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var particles : CPUParticles2D = $DefaultParticles

func activate(m:Map, r:Recipes, grid_mover:ModuleGridMover):
	self.map = m
	self.recipes = r
	grid_mover.cell_entered.connect(on_cell_entered)

func on_cell_entered(cell:Cell):
	# no potion here, do nothing
	var elem = cell.get_element()
	if not elem: return
	if not elem.is_potion(): return
	
	GDict.feedback.emit(cell.get_position(), "Break!")
	
	# @NOTE: This ensures shadows are correct when we try to do this
	await get_tree().process_frame
	
	# disassemble into the right elements
	var components = recipes.get_components_for(elem.type)
	
	if GConfig.potion_garbage_can_appear and randf() <= GConfig.potion_garbage_prob:
		components.pop_back()
		components.append(GDict.get_random_mutation())
	
	# distribute over valid cells
	var cells_allowed : Array[Cell] = map.query_cells({
		"shadow": false,
		"empty": true,
		"num": components.size()
	})

	for i in range(cells_allowed.size()):
		cells_allowed[i].add_element(components[i])
	
	# remove the actual potion
	cell.remove_element()
	
	audio_player.pitch_scale = randf_range(0.9, 1.1)
	audio_player.play()
	particles.play()
