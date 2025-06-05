extends Node2D
##################################################
##
##   This is the main file for my game.
##   Here are combined all the scripts for the
##   game and called in correct orders.
##
##################################################

## REFERENCES ##
var seed_manager: Node
var enemies_manager: Node
@onready var player: CharacterBody2D = $Player
@onready var world_tiles: TileMapLayer = $WorldTiles

## Player
# var playerPosition: Vector2 ## player position in pixels
# var playerTilePosition: Vector2 ## player position in map tiles


func _ready() -> void:
	## Create an instance of other scripts used as libraries
	seed_manager = preload("res://Scripts/world/set_seed.gd").new()
	enemies_manager = preload("res://Scripts/enemies/enemies_manager.gd").new()
	enemies_manager.loadScenes()
	
	## Set the seed
	seed_manager.getSeed()
	seed_manager.setSeed()
	
	## Add some enemies
	create_enemy("tripapie", 10, 70)
	create_enemy("tripapie", -50, -8)
	create_enemy("tripapie", 2, -30)
	create_enemy("chilli", 70, 40)
	create_enemy("chilli", -90, 80)
	create_enemy("chilli", -22, 30)

func _process(delta: float) -> void:
	check_health()


func create_enemy(enemyName, pos_x, pos_y):
	var instance = enemies_manager.create_an_enemy(enemyName, pos_x, pos_y)
	instance.player = player
	add_child(instance)

func check_health():
	if player.health <= 0:
		die()

func die():
	## restart
	print("YOU DIE")
	get_tree().reload_current_scene()
