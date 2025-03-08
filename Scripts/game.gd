extends Node2D
##################################################
## This file creates the world map and object map 
## and fills them
##
##################################################

###############
## VARIBALES ##
###############

## Map of mineable objects
	## 1-9 trees (1 green tree, 2 orange tree)
	## 10-19 rocks (10 small rock)
	## 20-29 flowers (20 pink flower, 21 red flower)
var objectMap: Array = []
## width and length of table - size (vedno kvadratno)
const objectMapSize: int = 100

## REFERENCES
@onready var player: CharacterBody2D = $Player
var playerPosition

## SCENES & INSTANCES
var objects = {
	"greenTree": {},
	"orangeTree": {},
	"smallRock": {},
	"pinkFlower": {},
	"redFlower": {}
}

func _ready() -> void:
	## Preload the scenes
	objects["greenTree"]["scene"] = preload("res://Scenes/greenTree.tscn")
	objects["orangeTree"]["scene"] = preload("res://Scenes/orangeTree.tscn")
	objects["smallRock"]["scene"] = preload("res://Scenes/smallRock.tscn")
	objects["pinkFlower"]["scene"] = preload("res://Scenes/pinkFlower.tscn")
	objects["redFlower"]["scene"] = preload("res://Scenes/redFlower.tscn")
	
	## CREATE & FILL THE OBJECT MAP ##
	var roll: float = 0.0
	var x: float
	var y: float
	for i in objectMapSize:
		objectMap.append([])
		for j in objectMapSize:
			roll = randf()
			x = ((i + 1) * 16) - ((objectMapSize * 16) / 2) - 8
			y = ((j + 1) * 16) - ((objectMapSize * 16) / 2) - 8
			if roll <= 0.8: # 80% chance za nič
				objectMap[i].append(0)
			elif roll <= 0.82: # 2%
				objectMap[i].append(1) ## green tree
				## DRAW OBJECTS ON MAP
				objects["greenTree"]["instance"] = objects["greenTree"]["scene"].instantiate()
				objects["greenTree"]["instance"].set_position(Vector2(x, y))
				add_child(objects["greenTree"]["instance"])
			elif roll <= 0.83: # 1%
				objectMap[i].append(2) ## orange tree
				objects["orangeTree"]["instance"] = objects["orangeTree"]["scene"].instantiate()
				objects["orangeTree"]["instance"].set_position(Vector2(x, y))
				add_child(objects["orangeTree"]["instance"])
			elif roll <= 0.85: # 2%
				objectMap[i].append(10) ## small rock
				objects["smallRock"]["instance"] = objects["smallRock"]["scene"].instantiate()
				objects["smallRock"]["instance"].set_position(Vector2(x, y))
				add_child(objects["smallRock"]["instance"])
			elif roll <= 0.95: # 10%
				objectMap[i].append(20) ## pink flower
				objects["pinkFlower"]["instance"] = objects["pinkFlower"]["scene"].instantiate()
				objects["pinkFlower"]["instance"].set_position(Vector2(x, y))
				add_child(objects["pinkFlower"]["instance"])
			else: # 5%
				objectMap[i].append(21) ## red flower
				objects["redFlower"]["instance"] = objects["redFlower"]["scene"].instantiate()
				objects["redFlower"]["instance"].set_position(Vector2(x, y))
				add_child(objects["redFlower"]["instance"])
	# print(objectMap)

func _process(delta: float) -> void:
	playerPosition = player.get_position()
	# print(playerPosition)
