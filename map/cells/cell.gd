class_name Cell extends Node2D

var pos : Vector2i = Vector2i.ZERO
var disabled : bool = false
var shadow : bool = false

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

func visualize(cell_size:float):
	floor_sprite.set_rotation(randi_range(0,3)*0.5*PI)
	floor_sprite.modulate = Color(1.0, 1.0, 1.0, randf_range(0.85, 1.0)).darkened(randf_range(0, 0.167))
	set_position(cell_size * Vector2(pos))
	set_visible(not disabled)

### Player management
func get_players():
	return players

func count_players() -> int:
	return players.size()

func has_player(p:Player) -> bool:
	return players.has(p)

func add_player(p:Player) -> bool:
	if has_player(p): return false
	players.append(p)
	return true

func remove_player(p:Player) -> bool:
	if not has_player(p): return false
	players.erase(p)
	return true

### Element management
func get_element() -> CellElement:
	return element

func add_element(e:String):
	var node = element_scene.instantiate()
	add_child(node)
	node.set_type(e)
	element = node
	
	node.set_scale(1.1*Vector2.ONE)
	get_tree().create_tween().tween_property(node, "scale", Vector2.ONE, 0.15)

func remove_element():
	element.queue_free()
	element = null

### Machine management
func get_machine_type() -> String:
	return machine_type

func add_machine(type:String):
	machine_type = type
	
	var node = element_scene.instantiate()
	add_child(node)
	node.set_type(type) 
	machine_node = node
	
	node.set_scale(1.1*Vector2.ONE)
	get_tree().create_tween().tween_property(node, "scale", Vector2.ONE, 0.15)
	
	var module_scene = GDict.MACHINES[type].module_scene
	if module_scene:
		var mod = module_scene.instantiate()
		node.add_child(mod)
		machine = mod

func remove_machine():
	machine_node.queue_free() # `machine` module automatically dies too because it's child of this
	machine_type = ""
	machine = null

func is_empty() -> bool:
	return not get_element() and count_players() <= 0 and get_machine_type() == ""

func is_edge(grid_size:Vector2i) -> bool:
	return pos.x <= 0 || pos.y <= 0 || pos.x >= (grid_size.x-1) || pos.y >= (grid_size.y-1)

func set_shadow(val:bool) -> void:
	var changed = shadow != val
	if not changed: return
	
	shadow = val
	
	var start_alpha = 0.0
	var end_alpha = 1.0
	if shadow: 
		start_alpha = 1.0
		end_alpha = 0.0
	
	var tween_dur = 0.1
	
	if element: 
		element.modulate.a = start_alpha
		get_tree().create_tween().tween_property(element, "modulate:a", end_alpha, tween_dur)
	if machine_type: 
		machine_node.modulate.a = start_alpha
		get_tree().create_tween().tween_property(machine_node, "modulate:a", end_alpha, tween_dur)
