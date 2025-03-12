extends Node

##################################################
##
##   This file draws the world map
##
##################################################

## References to other scripts used in this file
var world_gen
var game

## Dictionary of the objects with its scenes and instances
var objects = {
	"greenTree": {"instances": []},
	"orangeTree": {"instances": []},
	"smallRock": {"instances": []},
	"pinkFlower": {"instances": []},
	"redFlower": {"instances": []}
}

## Draw the objects from objectMap generated in world_gen.createObjectMap
func drawObjectMap():
	## set the seed each time before drawing so we always get the same outcome
	## setSeed.setSeed()
	
	## draw the map
	var flip: bool
	var x: float
	var y: float
	for i in world_gen.objectMapSize:
		for j in world_gen.objectMapSize:
			flip = randi() % 2 == 0
			x = ((i + 1) * 16) - ((world_gen.objectMapSize * 16) / 2) - 12 #??? zakaj 12 (če sm dala -8 -8 za obe so slightly off center)
			y = ((j + 1) * 16) - ((world_gen.objectMapSize * 16) / 2) - 0 #??? zakaj 0
			## DRAW OBJECTS ON MAP
			if (world_gen.objectMap[i][j] != "none"):
				## append instance to array of instances in the dictionary
				objects[world_gen.objectMap[i][j]]["instances"].append(objects[world_gen.objectMap[i][j]]["scene"].instantiate())
				objects[world_gen.objectMap[i][j]]["instances"].back().set_position(Vector2(x, y)) ## add position
				## flip the objects and its collision meshes
				if (flip):
					objects[world_gen.objectMap[i][j]]["instances"].back().scale.x *= -1
				## add to scene
				game.add_child(objects[world_gen.objectMap[i][j]]["instances"].back())

func preloadScenes():
	## Preload the scenes
	objects["greenTree"]["scene"] = preload("res://Scenes/greenTree.tscn")
	objects["orangeTree"]["scene"] = preload("res://Scenes/orangeTree.tscn")
	objects["smallRock"]["scene"] = preload("res://Scenes/smallRock.tscn")
	#objects["pinkFlower"]["scene"] = preload("res://Scenes/pinkFlower.tscn")
	#objects["redFlower"]["scene"] = preload("res://Scenes/redFlower.tscn")
