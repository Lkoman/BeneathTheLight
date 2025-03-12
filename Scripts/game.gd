extends Node2D
##################################################
##
##   This is the main file for my game.
##   Here are combined all the scripts for the
##   game and called in correct orders.
##
##################################################

## References to other scripts used in this file
var world_gen
var world_draw
var set_seed
var obj_manager

## REFERENCES ##
@onready var player: CharacterBody2D = $Player
@onready var world_tiles: TileMapLayer = $WorldTiles

var playerPosition ## player position in pixels
var playerTilePosition ## player position in map tiles

func _ready() -> void:
	## Create an instance of other scripts used as libraries
	world_gen = preload("res://Scripts/world/world_generation.gd").new()
	world_draw = preload("res://Scripts/world/world_draw.gd").new()
	set_seed = preload("res://Scripts/world/set_seed.gd").new()
	obj_manager = preload("res://Scripts/objects/object_manager.gd").new()
	
	## pass the instances that we are using here to world_draw.gd
	world_draw.game = self
	world_draw.world_gen = world_gen
	
	## Preload the scenes for objects
	world_draw.preloadScenes()
	
	## Set the seed
	set_seed.getSeed()
	set_seed.setSeed()
	
	## OLD GENERATION OF THE WORLD - WITH OBJECTS,
	## ZDEJ SM ŠLA Z TILEMAPLAYERS v file-u objects_tiles.gd
	## CREATE & FILL THE OBJECT MAP ##
	# world_gen.createObjectMap()
	# world_draw.drawObjectMap()


func _process(delta: float) -> void:
	playerPosition = player.get_position()
	playerTilePosition = world_tiles.local_to_map(playerPosition)
	
	# print(playerPosition)
