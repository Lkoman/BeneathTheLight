extends Node
###################################
##
## This file is responsible for spawning enemies
##
##
###################################

## VARIABLES
var enemies = {
	"tripapie": {"hp": 80,},
	"chilli": {"hp": 30,}
}
var tmpInstance

func _ready() -> void:
	loadScenes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

## Creates an instance of an object and drops it on the floor
func create_an_enemy(enemyName, pos_x, pos_y):
	## Call the item scene and create an instance of it
	tmpInstance = enemies[enemyName]["scene"].instantiate()
	## Place the instance where the object was + random nums
	tmpInstance.set_position(Vector2(pos_x, pos_y))
	
	## Add instance to scene
	return tmpInstance
	print("aaaa")

func loadScenes():
	print("aaaaaaaaa")
	enemies["tripapie"]["scene"] = preload("res://Scenes/Enemies/tripapie.tscn")
	enemies["chilli"]["scene"] = preload("res://Scenes/Enemies/chilli.tscn")
