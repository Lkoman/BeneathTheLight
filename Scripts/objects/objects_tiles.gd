extends TileMapLayer
################################################################
##
## This file is responsible for object collection on the 
## TileMapLayer ObjectTiles
##
## It checks for mouse inputs on specific coordinates of the
## TileMapLayer, checks for objects on that tileMap coordinate
## and mines them
##
## It also communicates with inventory for storing items
##
##################################################################

###############
## VARIABLES ##
###############

## World
var worldMouseCoordinates: Vector2 ## save the coordinates of the mouse
var mapCoordinates: Vector2 ## tileMapLayer coordinates

## Player
var playerPositionOnMap: Vector2 ## position of player on TileMapLayer
var camera = null ## camera object

## Mined object data
var miningObjectID: int ## the object that is being mined
var miningObjectCell: Vector2 ## the cell/coordinates (of the tileMapLayer) of the object being mined
var miningObjectCoordinates: Vector2 ## -||- world coordinates/viewport coordinates

## Inventory
var inventoryFull: bool

## REFERENCES
var playerNode
var set_seed
var inventory_manager

## Random numbers
var randNums: Array[float] = [0.0, 0.0]

## Dictionary to connect objects and items
## VALUES:
	## object and item names
	## item SCENE (created in loadScenes())
	## last item INSTANCE (created in DeleteCell())
var itemToObject = {
	## objectID: { object: objectName, item: itemName, scene: scene, instance: lastInstance}
	2: {"object": "tree", "item": "wood"},
	10: {"object": "redFlower", "item": "redFlower"},
	11: {"object": "pinkFlower", "item": "pinkFlower"},
}

func _ready() -> void:
	## load the scenes
	loadScenes()
	## get references
	getRerefrences()


func _process(delta: float) -> void:
	## get player position on tileMapLayer
	playerPositionOnMap = local_to_map(playerNode.get_position())
	# print(playerPositionOnMap)

## Handle events
func _input(event):
	## Mouse click
	if event is InputEventMouseButton:
		mouseClickHandle()


func mouseClickHandle():
	## Get mouse coordinates on the screen
	worldMouseCoordinates = camera.get_global_mouse_position()
	## Convert screen coordinates to tileMapLayer coordinates
	mapCoordinates = local_to_map(worldMouseCoordinates)
	
	## If there is an object on the mapCoordinates
	if (get_cell_source_id(mapCoordinates) != -1):
		## If the player is close to that object
		if (mapCoordinates.x <= playerPositionOnMap.x + 2 && mapCoordinates.x >= playerPositionOnMap.x - 2 &&
			mapCoordinates.y <= playerPositionOnMap.y + 3 && mapCoordinates.y >= playerPositionOnMap.y - 3):
			## Mine the object
			mineObject()

####################
## MINE AN OBJECT ##
####################
func mineObject():
	## Get the ID of the object
	miningObjectID = get_cell_source_id(mapCoordinates)
	
	## Check the itemToObject dictioary, if the object can drop an item
	if (!itemToObject.has(miningObjectID)):
		return 0
	
	#############################################################
	## If the object can drop an item, continue with mining it ##
	
	## The data I need about the cell/object being mined
	miningObjectCell = mapCoordinates ## tilemapLayer coordinates of the object
	miningObjectCoordinates = worldMouseCoordinates ## world coordinates of the object
	
	## Get the number of items that will be dropped after mining
	var numOfItems: int = randi_range(1, 2)
	
	## For every dropped item
	for num in numOfItems:
		## If the inventory is full, drop the item on the floor
		if (inventory_manager.isInventoryFull(miningObjectID)):
			## Create 2 random numbers for random drop of items (x and y)
			randNums[0] = randf_range(-20, 20)
			randNums[1] = randf_range(-20, 20)
		
			## Call the item scene and create an instance of it
			itemToObject[miningObjectID]["instance"] = itemToObject[miningObjectID]["scene"].instantiate()
			## Place the instance where the object was + random nums
			itemToObject[miningObjectID]["instance"].set_position(
				Vector2(miningObjectCoordinates.x + randNums[0], 
				miningObjectCoordinates.y + randNums[1]))
			## Add instance to scene
			add_child(itemToObject[miningObjectID]["instance"])
		
		## Otherwise add the mined item to the inventory
		else:
			inventory_manager.addItemToInventory(miningObjectID, itemToObject[miningObjectID]["scene"], 1)
	
	## Then erase the mined object
	erase_cell(miningObjectCell)
	
	###############################################
	## Objects can be composed of multiple tiles ##
	
	## IF the tile above it is the same object (trunk)
	if (get_cell_source_id(Vector2(mapCoordinates.x, mapCoordinates.y - 1)) == 2):
		## then set the needed data for that tile (-1 and -16)
		miningObjectCoordinates.y = miningObjectCoordinates.y - 16;
		miningObjectCell = Vector2(mapCoordinates.x, mapCoordinates.y - 1)
		mapCoordinates.y = mapCoordinates.y - 1
		## and call the function again - recursive
		mineObject()
	
	## ELSE IF the tile above it is the END of tree (canopy), just delete it
	elif (get_cell_source_id(Vector2(mapCoordinates.x, mapCoordinates.y - 1)) == 1):
		erase_cell(Vector2(mapCoordinates.x, mapCoordinates.y - 1))


## Necessary priprave za začetek igre ##
## Load the scenes of the objects / items
func loadScenes():
	## ITEMS
	itemToObject[2]["scene"] = preload("res://Scenes/item_wood.tscn")
	itemToObject[10]["scene"] = preload("res://Scenes/item_redFlower.tscn")
	itemToObject[11]["scene"] = preload("res://Scenes/item_pinkFlower.tscn")

## Get references to other nodes and scripts
func getRerefrences():
	## NODES
	playerNode = get_node("../Player")
	camera = get_viewport().get_camera_2d() ## get camera object
	
	## SCRIPTS
	set_seed = preload("res://Scripts/world/set_seed.gd").new()
	inventory_manager = preload("res://Scripts/player/inventory_manager.gd").new()
	
	## Send the instance of THIS script to inventory_manager.gd
	inventory_manager.objTiles = self
