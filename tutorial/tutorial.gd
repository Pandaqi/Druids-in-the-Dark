class_name Tutorial extends CanvasLayer

@onready var tut_image_1 : TextureRect = $Control/MarginContainer/MarginContainer/HBoxContainer/TutorialImageLeft
@onready var tut_image_2 : TextureRect = $Control/MarginContainer/MarginContainer/HBoxContainer/TutorialImageRight
@onready var tut_text : RichTextLabel = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/TutorialText

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var active := false
var tutorial_image_spritesheet : Texture = preload("res://main/sprites.webp") #preload("res://tutorial/spritesheet.webp")

signal dismissed()

func _input(ev):
	if not active: return
	if ev.is_action_released("interact_-1_0") or ev.is_action_released("interact_0_0"):
		dismiss()

func dismiss():
	set_visible(false)
	active = false
	emit_signal("dismissed")

func get_data_from_level(level:int) -> Dictionary:
	if level >= GDict.TUTORIAL_ORDER.size(): return {}
	var cur_tut := GDict.TUTORIAL_ORDER[level]
	if not cur_tut: return {}
	return GDict.TUTORIALS[cur_tut]

func load_default_properties():
	load_changes(GDict.TUTORIALS.default.changes)

func load_properties_of(level:int) -> void:
	var data := get_data_from_level(level)
	if data.keys().size() <= 0: return
	load_changes(data.changes)

func load_changes(changes:Dictionary):
	for key in changes:
		GConfig[key] = changes[key]

func display(level:int) -> void:
	var data := get_data_from_level(level)
	if data.keys().size() <= 0: return
	
	set_visible(true)
	active = true
	anim_player.play("tutorial_popup")
	
	# set tutorial text
	tut_text.set_text("[center]" + data.desc + "[/center]")
	
	# first image on left is optional (but will usually be set)
	var frame = data.frame if ("frame" in data) else 0
	
	var region = Rect2(frame * 128, 0, 128, 128)
	var a = AtlasTexture.new()
	a.atlas = tutorial_image_spritesheet
	a.region = region
	tut_image_1.texture = a
	
	# second image on right is optional; if not set, it shows a basic tutorial icon
	var frame2 = data.frame2 if ("frame2" in data) else 0
	var region2 = Rect2(frame2 * 128, 0, 128, 128)
	var a2 = AtlasTexture.new()
	a2.atlas = tutorial_image_spritesheet
	a2.region = region2
	tut_image_2.texture = a2
