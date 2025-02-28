extends TileMapLayer
## This file is responsible for object collection on the 
## TileMapLayer ObjectTiles
##
## It checks for mouse inputs on specific coordinates of the
## TileMapLayer, checks for objects on that tileMap coordinate
## and mines them

## VARIABLES
var worldMouseCoordinates = null ## save the coordinates of the mouse
var camera = null ## camera object
var mapCoordinates = null ## tileMapLayer coordinates
var isMining = bool() ## boolean for starting and ending mining
var miningObjectID = 0 ## the object that is being mined
var miningObjectCell = null ## the cell/coordinates (of the tileMapLayer) of the object being mined
var miningObjectCoordinates = null ## -||- world coordinates/viewport coordinates
var playerPositionOnMap = null

## REFERENCES
var playerNode = null

func _ready() -> void:
	## get references
	playerNode = get_node("../Player")
	## get camera object
	camera = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
	## get player position on tileMapLayer
	playerPositionOnMap = local_to_map(playerNode.get_position())
	print(playerPositionOnMap)

## Handle events
func _input(event):
	## Mouse click
	if event is InputEventMouseButton:
		mouseClickHandle()

func mouseClickHandle():
	## get mouse coordinates on the screen
	worldMouseCoordinates = camera.get_global_mouse_position()
	## convert screen coordinates to tileMapLayer coordinates
	mapCoordinates = local_to_map(worldMouseCoordinates)
	
	## if there is an object on the mapCoordinates
	if (get_cell_source_id(mapCoordinates) != -1):
		## if the player is close to that object
		if (mapCoordinates.x <= playerPositionOnMap.x + 2 && mapCoordinates.x >= playerPositionOnMap.x - 2 &&
			mapCoordinates.y <= playerPositionOnMap.y + 3 && mapCoordinates.y >= playerPositionOnMap.y - 3):
			if (!isMining):
				## if mining just started, set isMining to true and save
				## the data I need about the cell/object being mined
				isMining = true
				miningObjectID = get_cell_source_id(mapCoordinates)
				miningObjectCell = mapCoordinates
				miningObjectCoordinates = worldMouseCoordinates
			else:
				## if mining ended, erase the cell and drop items
				isMining = false
				## TREES
				if (miningObjectID == 2 || miningObjectID == 5):
					var woodScene = load("res://Scenes/item_wood.tscn")
					var instance = woodScene.instantiate()
					instance.set_position(miningObjectCoordinates)
					add_child(instance)
					erase_cell(miningObjectCell)
			
			print(miningObjectID, " ", isMining)
