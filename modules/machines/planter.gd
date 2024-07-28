class_name ModulePlanter extends Node2D

@onready var sprite : InventoryItem = $InventoryItem
@onready var timer : Timer = $Timer
@onready var cell : Cell = get_parent().get_parent()
var type : String

func _ready():
	timer.timeout.connect(on_timer_timeout)
	restart_timer()

func restart_timer():
	timer.wait_time = randf_range(GConfig.planter_cell_timer.min, GConfig.planter_cell_timer.max)
	timer.start()

func set_type(tp:String) -> void:
	type = tp
	sprite.set_frame(GDict.get_element_data(tp).frame)

func on_timer_timeout():
	restart_timer()
	
	var can_add = not cell.has_players() and not cell.get_element() and not cell.shadow
	if not can_add: return
	cell.add_element(type)
