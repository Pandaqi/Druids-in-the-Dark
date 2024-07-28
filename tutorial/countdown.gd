class_name Countdown extends CanvasLayer

@onready var cont : CenterContainer = $Control/CenterContainer
@onready var label : Label = $Control/CenterContainer/Label

signal is_done()

var seconds := 0

func _ready():
	set_visible(false)

func appear():
	set_visible(true)
	update_seconds(GConfig.countdown_num_seconds)

func disappear():
	set_visible(false)
	seconds = 0

func _on_timer_timeout() -> void:
	update_seconds(-1)

func update_seconds(ds:int) -> void:
	seconds += ds
	
	if seconds <= 0:
		is_done.emit()
		disappear()
		return
	
	label.set_text(str(seconds))
	
	cont.set_scale(2*Vector2.ONE)
	var tw = get_tree().create_tween()
	tw.tween_property(cont, "scale", 0.1*Vector2.ONE, 1.0)
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_callback(_on_timer_timeout)
