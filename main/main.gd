extends Node2D

@onready var map : Map = $Map
@onready var players : Players = $Players
@onready var recipes : Recipes = $Recipes
@onready var shadows : Shadows = $Shadows
@onready var progression : Progression = $Progression
@onready var cam : Camera2D = $Camera2D

func _ready() -> void:
	progression.activate(map)
	map.activate(progression)
	players.activate(map, recipes, shadows)
	recipes.activate(progression)
	shadows.activate(map, players)
	cam.activate(map)
