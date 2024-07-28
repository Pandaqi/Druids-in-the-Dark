extends Control

@onready var player_id : Label = $MarginContainer/VBoxContainer/PlayerID
@onready var instruction : Label = $MarginContainer/VBoxContainer/Instruction
@onready var bg = $NinePatchRect
var active := true

func init(num:int):
	player_id.set_text("Player " + str(num + 1))

func activate():
	if active: return
	active = true
	
	instruction.set_visible(false)
	bg.modulate.a = 1.0

func deactivate(show_instruction:bool = false):
	instruction.set_visible(show_instruction)
	
	if not active: return
	bg.modulate.a = 0.2
	active = false

# @TODO: display proper input hints for this player + already allow them to move around within their container?
