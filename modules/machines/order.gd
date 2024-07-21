class_name ModuleOrder extends Node2D

# @TODO: save the recipe we want, display it, update a timer
var recipe:String = ""
@onready var timer : Timer = $Timer

func _ready():
	# @TODO: slightly randomize the duration? make it depend on other factors?
	timer.wait_time = randf_range(25,60)
	timer.timeout.connect(on_timer_timeout)
	timer.start()

func add_recipe(r:String) -> void:
	self.recipe = r

func get_recipe() -> String:
	return recipe

func is_occupied():
	return recipe != ""

func _physics_process(dt:float) -> void:
	var timer_left = timer.time_left / timer.wait_time
	# @TODO: display/use this for progress bar

func on_timer_timeout():
	GDict.emit_signal("game_over", false)
