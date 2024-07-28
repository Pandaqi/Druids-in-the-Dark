extends Control

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(preload("res://game_loop/input_select.tscn"))

func _on_quit_pressed() -> void:
	get_tree().quit()
