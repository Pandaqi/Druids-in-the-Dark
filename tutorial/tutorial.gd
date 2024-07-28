class_name Tutorial extends CanvasLayer

@onready var tut_image_1 : TextureRect = $Control/MarginContainer/MarginContainer/HBoxContainer/TutorialImageLeft
@onready var tut_image_2 : TextureRect = $Control/MarginContainer/MarginContainer/HBoxContainer/TutorialImageRight
@onready var tut_text : RichTextLabel = $Control/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/TutorialText

@onready var anim_player : AnimationPlayer = $AnimationPlayer

var active := false
var tutorial_image_spritesheet : Texture = preload("res://tutorial/tutorials.webp")

signal dismissed()

func _input(ev):
	if not active: return
	if ev.is_action_released("interact_-1_0") or ev.is_action_released("interact_0_0"):
		dismiss()

func dismiss():
	set_visible(false)
	active = false
	dismissed.emit()

# @NOTE: this would be used if I ever make a savegame functionality, and you can restart from any level
func load_cumulative_properties_until(level:int):
	load_default_properties()
	for i in range(level+1):
		load_properties_of(i)

func get_data_from_level(level:int) -> Dictionary:
	if level >= GDict.TUTORIAL_ORDER.size(): return {}
	var cur_tut := GDict.TUTORIAL_ORDER[level]
	if not cur_tut: return {}
	return GDict.TUTORIALS[cur_tut]

func load_default_properties():
	load_changes(GDict.TUTORIALS.default.changes)
	GConfig.machines_included = []

func load_properties_of(level:int) -> void:
	var data := get_data_from_level(level)
	if data.keys().size() <= 0: return
	
	load_changes(data.changes)
	if "machines" in data:
		GConfig.machines_included += data.machines

func load_changes(changes:Dictionary):
	for key in changes:
		GConfig[key] = changes[key]

func display(level:int) -> void:
	var data := get_data_from_level(level)
	print("Should display tutorial")
	print(level)
	print(data)
	if data.keys().size() <= 0: 
		await get_tree().process_frame
		dismiss()
		return
	
	print("Displaying tutorial")
	
	set_visible(true)
	anim_player.stop(false)
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
	
	await anim_player.animation_finished
	active = true
