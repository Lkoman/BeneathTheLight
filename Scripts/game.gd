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
@onready var ui: CanvasLayer = $"UI"

var map_size := [25, 25]

func _ready() -> void:
	## Create an instance of other scripts used as libraries
	seed_manager = preload("res://Scripts/world/set_seed.gd").new()
	enemies_manager = preload("res://Scripts/enemies/enemies_manager.gd").new()
	enemies_manager.loadScenes()
	
	## Set the seed
	seed_manager.getSeed()
	seed_manager.setSeed()
	
	## Add some enemies
	#create_num_of_enemies("Chicken", 10)
	#create_num_of_enemies("Chilli", 30)

func _process(delta: float) -> void:
	check_health()

func create_num_of_enemies(enemy_name, num_of_enemies):
	for n in num_of_enemies:
		create_enemy(enemy_name, randf_range(-map_size[0] * 16, map_size[0] * 16), randf_range(-map_size[1] * 16, map_size[1] * 16), n)

func create_enemy(enemy_name, pos_x, pos_y, enemy_count):
	var instance = enemies_manager.create_an_enemy(enemy_name, pos_x, pos_y)
	instance.player = player
	instance.spawn_position = Vector2(pos_x, pos_y)
	instance.name = "%s_%d" % [enemy_name, enemy_count]
	add_child(instance)

func check_health():
	if player.health <= 0:
		die()

func die():
	## restart
	print("YOU DIE")
	get_tree().reload_current_scene()
