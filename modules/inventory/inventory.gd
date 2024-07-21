class_name ModuleInventory extends Node2D

var items : Array[String] = []

func activate():
	pass

func set_content(new_items:Array[String]):
	items = new_items
	items.sort()
	visualize()

func get_content():
	return items.duplicate(false)

func count():
	return items.size()

func clear():
	items.clear()
	visualize()

func visualize():
	pass
	# @TODO
