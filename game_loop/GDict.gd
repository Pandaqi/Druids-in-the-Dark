extends Node

signal game_over(we_win:bool)

const ELEMENTS = {
	"a": { "frame": 0 },
	"b": { "frame": 1 },
	"c": { "frame": 2 },
	"d": { "frame": 3 },
	"e": { "frame": 4 },
}

const POTIONS = {
	"a": { "frame": 0 },
	"b": { "frame": 1 },
	"c": { "frame": 2 },
	"d": { "frame": 3 },
	"e": { "frame": 4 },
}

const MACHINES = {
	"recipe_book": { "frame": 0, "module_scene": preload("res://modules/machines/recipe_book.tscn") },
	"order": { "frame": 1, "module_scene": preload("res://modules/machines/order.tscn") },
	"garbage_bin": { "frame": 2, "module_scene": null }
}
