class_name Cell extends Node2D

var pos : Vector2i = Vector2i.ZERO
var disabled : bool = false
var shadow : bool = false

var floor_tween : Tween
var element_tween : Tween
var machine_tween : Tween

# cells can hold any number of players ( = moving entities)
var players : Array[Player] = []

# cells can hold 0 or 1 element (potion or component)
var element : CellElement = null

# cells can hold 0 or 1 machines (the "special thing" that a cell can be)
# if so, it also instantiates the specific module for it under `machine` (if possible/exists)
var machine_type : String = ""
var machine_node : CellElement = null
var machine = null

@export var element_scene : PackedScene
@onready var floor_sprite = $Floor
@onready var shadow_time_tracker : ModuleShadowTimeTracker = $ShadowTimeTracker
@onready var shadow_event_player : AudioStreamPlayer2D = $ShadowEventPlayer
@onready var shadow_event_particles : CPUParticles2D = $ShadowEventParticles

signal shadow_changed(val:bool)

func _ready():
	shadow_time_tracker.activate()

func visualize():
	floor_sprite.set_rotation(randi_range(0,3)*0.5*PI)
	floor_sprite.modulate = Color(1.0, 1.0, 1.0, randf_range(0.85, 1.0)).darkened(randf_range(0, 0.167))
	set_position(GConfig.cell_size * Vector2(pos))
	set_visible(not disabled)

### Player management
func get_players():
	return players

func count_players() -> int:
	return players.size()

func has_players() -> bool:
	return count_players() > 0

func has_player(p:Player) -> bool:
	return players.has(p)

func add_player(p:Player) -> bool:
	if has_player(p): return false
	players.append(p)
	on_player_entered(p)
	return true

func remove_player(p:Player) -> bool:
	if not has_player(p): return false
	players.erase(p)
	return true


func on_player_entered(p:Player) -> void:
	if get_machine_type():
		machine_node.play_tween()

### Element management
func get_element() -> CellElement:
	return element

func get_element_type() -> String:
	if not get_element(): return ""
	return get_element().type

func add_element(e:String) -> void:
	var node = element_scene.instantiate()
	add_child(node)
	node.set_type(e)
	element = node
	
	shadow_time_tracker.reset()
	
	if not GConfig.debug_disable_tweens:
		node.set_scale(1.1*Vector2.ONE)
		var tw = get_tree().create_tween()
		tw.tween_property(node, "scale", Vector2.ONE, 0.15)
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)

func remove_element() -> void:
	element.queue_free()
	element = null

func mutate() -> void:
	if not get_element(): return
	var old_alpha := element.modulate.a
	remove_element()
	add_element(GDict.get_random_mutation())
	element.modulate.a = old_alpha
	GDict.feedback.emit(get_position(), "Mutate!")
	
	trigger_shadow_event()

func trigger_shadow_event() -> void:
	shadow_event_player.pitch_scale = randf_range(0.9, 1.1)
	shadow_event_player.play()
	
	shadow_event_particles.play()

### Machine management
func get_machine_type() -> String:
	return machine_type

func add_machine(type:String) -> void:
	machine_type = type
	
	var node = element_scene.instantiate()
	add_child(node)
	node.set_type(type) 
	machine_node = node
	
	if not GConfig.debug_disable_tweens:
		node.set_scale(1.1*Vector2.ONE)
		var tw = get_tree().create_tween()
		tw.tween_property(node, "scale", Vector2.ONE, 0.15)
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	var mod_scene_path : String = GDict.MACHINES[type].module_scene
	if mod_scene_path:
		var module_scene = load(mod_scene_path)
		var mod = module_scene.instantiate()
		node.add_child(mod)
		machine = mod

func remove_machine() -> void:
	# must come before machine_node deletion
	if machine:
		if machine.has_method("finish"): machine.finish()
		machine.queue_free()
		machine = null
	
	machine_node.queue_free() # `machine` module automatically dies too because it's child of this
	machine_type = ""

func is_empty() -> bool:
	return (not get_element()) and count_players() <= 0 and get_machine_type() == ""

func is_edge(grid_size:Vector2i) -> bool:
	return pos.x <= 0 || pos.y <= 0 || pos.x >= (grid_size.x-1) || pos.y >= (grid_size.y-1)

func set_shadow(val:bool) -> void:
	var changed := shadow != val
	if not changed: return
	
	shadow = val
	shadow_changed.emit(val)
	
	var start_alpha := 0.0
	var end_alpha := 1.0
	if shadow: 
		start_alpha = 1.0
		end_alpha = 0.0
	
	var tween_dur = 0.1
	
	if GConfig.disabled_cells_kill_you:
		if GConfig.debug_disable_tweens:
			floor_sprite.modulate.a = end_alpha
		else:
			floor_sprite.modulate.a = start_alpha
			var tw = get_tree().create_tween()
			tw.tween_property(floor_sprite, "modulate:a", end_alpha, tween_dur)
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			floor_tween = tw
	
	if element: 
		if GConfig.debug_disable_tweens:
			element.modulate.a = end_alpha
		else:
			element.modulate.a = start_alpha
			var tw = get_tree().create_tween()
			tw.tween_property(element, "modulate:a", end_alpha, tween_dur)
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			element_tween = tw
	
	if machine_type: 
		if GConfig.debug_disable_tweens:
			machine_node.modulate.a = end_alpha
		else:
			machine_node.modulate.a = start_alpha
			var tw = get_tree().create_tween()
			tw.tween_property(machine_node, "modulate:a", end_alpha, tween_dur)
			tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			machine_tween = tw

func kill():
	if floor_tween: floor_tween.kill()
	if element_tween: element_tween.kill()
	if machine_tween: machine_tween.kill()
	
	if element: remove_element()
	if machine_type: remove_machine()
	
	self.queue_free()
