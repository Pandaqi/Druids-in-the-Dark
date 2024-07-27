class_name ModulePlayerShadow extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var entity = get_parent()

var range : int = GConfig.def_shadow_size[GInput.get_player_count()]

func activate(player_num: int, effects_tracker:ModuleEffectsTracker):
	effects_tracker.effects_changed.connect(on_effects_changed)
	
	GDict.toggle_shadows_globally.connect(on_shadows_toggled)
	
	sprite.modulate = GDict.PLAYER_COLORS[player_num]
	sprite.modulate.a = 0.863
	update_range(0)
	
	var tw = get_tree().create_tween()
	tw.set_loops()
	tw.tween_property(self, "scale", 0.925*Vector2.ONE, 0.5)
	tw.tween_property(self, "scale", 1.0*Vector2.ONE, 0.5)
	
	var tw2 = get_tree().create_tween()
	tw2.set_loops()
	tw2.tween_property(self, "modulate:a", 0.85, 0.763)
	tw2.tween_property(self, "modulate:a", 1.0, 0.763)

func update_range(dr:int):
	range = clamp(range + dr, 1, 5)
	sprite.set_scale((1.0 + 2*range)*Vector2.ONE)

func on_effects_changed(eff:Array[String]) -> void:
	if not GConfig.delivered_components_create_effects: return
	
	for elem in eff:
		var data = GDict.get_element_data(elem)
		if data.effect == "shadow_plus": update_range(1)
		elif data.effect == "shadow_min": update_range(-1)

func on_shadows_toggled(in_shadow:bool) -> void:
	set_visible(in_shadow)
