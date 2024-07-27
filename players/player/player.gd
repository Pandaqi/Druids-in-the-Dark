class_name Player extends Node2D

@onready var visuals : ModuleVisuals = $Visuals
@onready var input : ModuleInput = $Input
@onready var grid_mover : ModuleGridMover = $GridMover
@onready var inventory : ModuleInventory = $Inventory
@onready var player_interactor : ModulePlayerInteractor = $PlayerInteractor
@onready var potion_breaker : ModulePotionBreaker = $PotionBreaker
@onready var order_giver : ModuleOrderGiver = $OrderGiver
@onready var recipe_reader : ModuleRecipeReader = $RecipeReader
@onready var wildcard_reader : ModuleWildcardReader = $WildcardReader
@onready var element_grabber : ModuleElementGrabber = $ElementGrabber
@onready var element_dropper : ModuleElementDropper = $ElementDropper
@onready var player_shadow : ModulePlayerShadow = $PlayerShadow
@onready var effects_tracker : ModuleEffectsTracker = $EffectsTracker
@onready var teleporter : ModuleTeleporter = $Teleporter

func activate(player_num:int, map:Map, recipes:Recipes):
	input.activate(player_num)
	visuals.activate(grid_mover, effects_tracker)
	grid_mover.activate(map, input)
	inventory.activate()
	
	player_interactor.activate(grid_mover, effects_tracker)
	potion_breaker.activate(map, recipes, grid_mover)
	order_giver.activate(grid_mover, recipes, inventory)
	
	recipe_reader.activate(recipes, grid_mover, effects_tracker)
	wildcard_reader.activate(recipes, grid_mover, effects_tracker)
	
	element_grabber.activate(grid_mover, inventory)
	element_dropper.activate(grid_mover, inventory)
	player_shadow.activate(player_num, effects_tracker)
	effects_tracker.activate(order_giver)
	
	teleporter.activate(grid_mover, map)
