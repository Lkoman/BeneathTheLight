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
const objectMapSize: int = 16

var playerPosition
var playerTilePosition

## REFERENCES
@onready var player: CharacterBody2D = $Player
@onready var world_tiles: TileMapLayer = $WorldTiles
@onready var objects_tiles: TileMapLayer = $ObjectsTiles

## Dictionary of the objects with its scenes and instances
var objects = {
	"greenTree": {"instances": []},
	"orangeTree": {"instances": []},
	"smallRock": {"instances": []},
	"pinkFlower": {"instances": []},
	"redFlower": {"instances": []}
}

func _ready() -> void:
	## Set the seed
	#seed(123)
	## Preload the scenes
	objects["greenTree"]["scene"] = preload("res://Scenes/greenTree.tscn")
	objects["orangeTree"]["scene"] = preload("res://Scenes/orangeTree.tscn")
	objects["smallRock"]["scene"] = preload("res://Scenes/smallRock.tscn")
	objects["pinkFlower"]["scene"] = preload("res://Scenes/pinkFlower.tscn")
	objects["redFlower"]["scene"] = preload("res://Scenes/redFlower.tscn")
	
	## CREATE & FILL THE OBJECT MAP ##
	createObjectMap()
	drawObjectMap()

func _process(delta: float) -> void:
	playerPosition = player.get_position()
	playerTilePosition = world_tiles.local_to_map(playerPosition)
	
	# print(playerTilePosition)
	
func drawObjectMap():
	var flip: bool
	var x: float
	var y: float
	for i in objectMapSize:
		for j in objectMapSize:
			flip = randi() % 2 == 0
			x = ((i + 1) * 16) - ((objectMapSize * 16) / 2) - 8
			y = ((j + 1) * 16) - ((objectMapSize * 16) / 2) - 8
			## DRAW OBJECTS ON MAP
			if (objectMap[i][j] != "none"):
				objects[objectMap[i][j]]["instances"].append(objects[objectMap[i][j]]["scene"].instantiate())
				objects[objectMap[i][j]]["instances"].back().set_position(Vector2(x, y))
				if flip:
					objects[objectMap[i][j]]["instances"].back().find_children("Sprite2D")[0].set_flip_h(true)
				else:
					objects[objectMap[i][j]]["instances"].back().find_children("Sprite2D")[0].set_flip_h(false)
				add_child(objects[objectMap[i][j]]["instances"].back())

## CREATE OBJECT MAP AND FILL IT
	## Using ranf for randomness
func createObjectMap():
	var roll: float = 0.0
	for i in objectMapSize:
		objectMap.append([])
		for j in objectMapSize:
			roll = randf()
			if roll <= 0.9: # 80% chance za nič
				objectMap[i].append("none")
			elif roll <= 0.91: # 1%
				objectMap[i].append("greenTree") ## green tree
			elif roll <= 0.915: # 0.5%
				objectMap[i].append("orangeTree") ## orange tree
			elif roll <= 0.925: # 1%
				objectMap[i].append("smallRock") ## small rock
			elif roll <= 0.975: # 5%
				objectMap[i].append("pinkFlower") ## pink flower
			else: # 2.5%
				objectMap[i].append("redFlower") ## red flower
