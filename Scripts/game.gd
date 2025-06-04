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
@onready var player: CharacterBody2D = $Player
@onready var world_tiles: TileMapLayer = $WorldTiles

## Player
# var playerPosition: Vector2 ## player position in pixels
# var playerTilePosition: Vector2 ## player position in map tiles


func _ready() -> void:
	## Create an instance of other scripts used as libraries
	seed_manager = preload("res://Scripts/world/set_seed.gd").new()
	
	## Set the seed
	seed_manager.getSeed()
	seed_manager.setSeed()


func _process(delta: float) -> void:
	pass
	# playerPosition = player.get_position()
	# playerTilePosition = world_tiles.local_to_map(playerPosition)
	
	# print(playerPosition)
