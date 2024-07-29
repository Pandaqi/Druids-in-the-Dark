class_name GameOver extends CanvasLayer

@onready var anim_player : AnimationPlayer = $AnimationPlayer
@onready var label_heading : Label = $Control/MarginContainer/MarginContainer/VBoxContainer/Heading
@onready var label_body : RichTextLabel = $Control/MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/Result
@onready var continue_button : Button = $Control/MarginContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/Continue

var active := false
var we_won : bool = false
var run_is_over : bool = false
var progression : Progression

func activate(prog:Progression):
	progression = prog
	set_visible(false)

func appear(we_win:bool, level:int):
	we_won = we_win
	set_visible(true)
	
	var score = round(progression.score)
	
	var txt_heading = "Day Complete!" if we_won else "Game Over!"
	var txt_body = "You have reached [b]Level " + str(level + 1) + "[/b].\n\nYour score, which the druids secretly track, is [b]" + str(score) + " Points[/b]."
	var txt_continue_button = "Continue" if we_won else "Play Again"
	
	if level > GConfig.max_levels_per_run:
		run_is_over = true
		txt_heading = "Game Complete!"
		txt_continue_button = "Play Again"
		txt_body = "You have finished Level " + str(GConfig.max_levels_per_run) + ". This was the final level.\n\nYour final secret score is [b]" + str(score) + " Points[/b].\n\nCongratulations! You beat the game!"
	
	txt_continue_button += " (SPACE / ANY)"
	continue_button.set_text(txt_continue_button)
	
	label_heading.set_text(txt_heading)
	label_body.set_text("[center]" + txt_body + "[/center]") 
	
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
		on_continue_pressed()
	
	if ev.is_action_released("game_over_back"):
		on_back_pressed()

func on_continue_pressed():
	if we_won:
		disappear()
		progression.start_level()
	
	if not we_won or run_is_over:
		get_tree().reload_current_scene()

func on_back_pressed():
	get_tree().change_scene_to_packed(preload("res://game_loop/menu.tscn"))
