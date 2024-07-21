class_name Player extends Node2D

@onready var visuals : ModuleVisuals = $Visuals
@onready var input : ModuleInput = $Input
@onready var grid_mover : ModuleGridMover = $GridMover
@onready var inventory : ModuleInventory = $Inventory
@onready var player_interactor : ModulePlayerInteractor = $PlayerInteractor
@onready var potion_breaker : ModulePotionBreaker = $PotionBreaker
@onready var order_giver : ModuleOrderGiver = $OrderGiver
@onready var recipe_reader : ModuleRecipeReader = $RecipeReader
@onready var element_grabber : ModuleElementGrabber = $ElementGrabber
@onready var element_dropper : ModuleElementDropper = $ElementDropper
@onready var player_shadow : ModulePlayerShadow = $PlayerShadow

func activate(player_num:int, map:Map, recipes:Recipes):
	input.activate(player_num)
	visuals.activate(grid_mover)
	grid_mover.activate(map, input)
	inventory.activate()
	
	player_interactor.activate(grid_mover)
	potion_breaker.activate(map, recipes, grid_mover)
	order_giver.activate(grid_mover, recipes, inventory)
	recipe_reader.activate(recipes, grid_mover)
	
	element_grabber.activate(grid_mover, inventory)
	element_dropper.activate(grid_mover, inventory)
	player_shadow.activate()
