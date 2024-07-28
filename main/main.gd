extends Node2D

@onready var map : Map = $Map
@onready var players : Players = $Players
@onready var recipes : Recipes = $Recipes
@onready var shadows : Shadows = $Shadows
@onready var progression : Progression = $Progression
@onready var cam : Camera2D = $Camera2D
@onready var countdown : Countdown = $Countdown
@onready var tutorial : Tutorial = $Tutorial
@onready var game_over : GameOver = $GameOver

func _ready() -> void:
	progression.activate(map, tutorial, countdown, shadows, game_over, players, recipes)
	
	players.activate(map, recipes, shadows)
	map.activate(progression, players)
	recipes.activate(progression)
	shadows.activate(map, players)
	cam.activate(map)
	game_over.activate(progression)
	
	progression.start_level()
