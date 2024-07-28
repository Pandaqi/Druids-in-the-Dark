class_name ModuleEffectsTracker extends Node

var prev_components : Array[String] = []
var non_interact := false

signal effects_changed(eff:Array[String])

func activate(order_giver:ModuleOrderGiver):
	order_giver.order_delivered.connect(on_order_delivered)

func has_component(c:String):
	return prev_components.has(c)

func on_order_delivered(new_components:Array[String]):
	prev_components = new_components
	
	non_interact = false
	for elem in prev_components:
		var data = GDict.get_element_data(elem)
		if data.effect == "non_interact": non_interact = true
	
	effects_changed.emit(prev_components)
