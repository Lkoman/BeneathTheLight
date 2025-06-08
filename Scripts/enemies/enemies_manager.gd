extends Node
###################################
##
## This file is responsible for spawning enemies
##
##
###################################

## VARIABLES
var enemies = {
	"Tripapie": {},
	"Chilli": {},
	"Chicken": {},
}
var tmpInstance

func _ready() -> void:
	loadScenes()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die(enemy_node):
	enemy_node.queue_free()

## Creates an instance of an object and drops it on the floor
func create_an_enemy(enemyName, pos_x, pos_y):
	tmpInstance = enemies[enemyName]["scene"].instantiate()
	tmpInstance.set_position(Vector2(pos_x, pos_y))
	tmpInstance.enemies_manager = self
	
	## Add instance to scene
	return tmpInstance

func new_rand_vector_around_spawn(spawn_position, offset):
	return Vector2(randi_range(spawn_position.x - offset, spawn_position.x + offset), 
				   randi_range(spawn_position.y - offset, spawn_position.y + offset))

func loadScenes():
	enemies["Tripapie"]["scene"] = preload("res://Scenes/Enemies/tripapie.tscn")
	enemies["Chilli"]["scene"] = preload("res://Scenes/Enemies/chilli.tscn")
	enemies["Chicken"]["scene"] = preload("res://Scenes/Enemies/chicken.tscn")
