class_name GameOver extends CanvasLayer

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var label_heading : Label = $Control/MarginContainer/MarginContainer/VBoxContainer/Heading
@onready var label_body : Label = $Control/MarginContainer/MarginContainer/VBoxContainer/Result

var active := false
var we_won : bool
var progression : Progression

func activate(prog:Progression):
	progression = prog
	set_visible(false)

func appear(we_win:bool, level:int):
	we_won = we_win
	set_visible(true)
	
	var txt_heading = "Day Complete!" if we_won else "Game Over!"
	var txt_body = "You have reached level " + str(level + 1) + "."
	label_heading.set_text(txt_heading)
	label_body.set_text(txt_body) 
	
	anim_player.play("go_appear")
	await anim_player.animation_finished
	active = true

func disappear():
	active = false
	anim_player.play_backwards("go_appear")
	await anim_player.animation_finished
	set_visible(false)

func _input(ev):
	if not active: return
	if ev.is_action_released("game_over_restart"):
		if we_won:
			disappear()
			progression.start_level()
		else: 
			get_tree().reload_current_scene()
	
	if ev.is_action_released("game_over_back"):
		get_tree().change_scene_to_packed(preload("res://game_loop/menu.tscn"))
