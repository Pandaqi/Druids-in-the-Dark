class_name ModuleInventory extends Node2D

var items : Array[String] = []
var item_scene : PackedScene = preload("res://modules/inventory/inventory_item.tscn")
var item_nodes : Array[Node2D] = []
@export var pos_offset : Vector2 = Vector2.ZERO
@export var group_by_type : bool = false
@export var max_size : int = -1
@export var wrap_after_cols : int = -1 # the NUMBER of colums after which to wrap; -1 = none

func _ready():
	if max_size < 0: max_size = GConfig.inventory_max_size
	set_scale(GConfig.inventory_scale*Vector2.ONE)

func activate():
	pass

func add_content(item:String) -> void:
	if is_full(): return
	items.append(item)
	items.sort()
	visualize()

func set_content(new_items:Array[String]) -> void:
	items = new_items.slice(0, max_size)
	items.sort()
	visualize()

func is_full():
	return count() >= max_size

func get_content() -> Array[String]:
	return items.duplicate(false)

func has_content():
	return count() > 0

func count() -> int:
	return items.size()

func clear() -> void:
	items.clear()
	visualize()

func visualize():
	
	# give feedback audio, but only if possible (node exists)
	if has_node("AudioStreamPlayer2D"): 
		var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	
	# determine list of things based on display type
	var list : Array[String] = items.duplicate(false)
	
	var list_freq : Array[int] = []
	if group_by_type:
		list = []
		
		for elem in items:
			var idx = list.find(elem)
			if idx < 0:
				list.append(elem)
				list_freq.append(1)
			else:
				list_freq[idx] += 1
	
	# make sure we have enough nodes
	var num_items := list.size()
	while item_nodes.size() < num_items:
		var item_node := item_scene.instantiate()
		add_child(item_node)
		item_nodes.append(item_node)
	
	
	var num_cols := num_items
	var num_rows := 1
	if wrap_after_cols > 0:
		num_cols = min(wrap_after_cols, num_items)
		num_rows = ceil(num_items / float(wrap_after_cols))
	
	var offset_per_item := Vector2.ONE * 512.0
	
	var offset_all_items := Vector2(
		-0.5 * (num_cols - 1),
		-0.5 * (num_rows - 1)
	) * offset_per_item
	
	var cur_pos := offset_all_items
	for i in range(item_nodes.size()):
		var node := item_nodes[i]
		var item_has_content := i < num_items
		node.set_visible(item_has_content)
		
		if item_has_content:
			var data = GDict.get_element_data(list[i])
			node.set_frame(data.frame)
			if group_by_type:
				node.set_number(list_freq[i])

			node.set_position(cur_pos)
			cur_pos += Vector2(offset_per_item.x, 0)
			
			var wrap_line = (i+1) % wrap_after_cols == 0
			if wrap_line:
				cur_pos = Vector2(offset_all_items.x, cur_pos.y + offset_per_item.y)
			
