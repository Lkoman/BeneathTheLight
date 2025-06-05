extends TileMapLayer
##########################################################################
##
## This file is responsible for managing objects on the 
## TileMapLayer ObjectTiles
##
## Object mining, pick up
##
## It also communicates with inventory_manager.gd for storing items
##
#########################################################################

## REFERENCES to other nodes and scripts used in this script
@onready var playerNode: CharacterBody2D = $"../Player"
@onready var camera: Camera2D = $"../Player/Camera2D"
# var seed_manager: Node
var inventory_manager: Node
var player_interactions: Node

###############
## VARIABLES ##
###############

## World
var mouseScreenCoords: Vector2 ## save the coordinates of the mouse
var mapLayerCoords: Vector2 ## tileMapLayer coordinates

## Player
var playerCoordsTileMapLayer: Vector2 ## position of player on TileMapLayer
var interact := false

## Mined object data
var miningObjectID: int ## the object that is being mined
var miningObjectCell: Vector2 ## the cell/coordinates (of the tileMapLayer) of the object being mined
var miningObjectCoordinates: Vector2 ## -||- world coordinates/viewport coordinates

## Random numbers
var randNums: Array[float] = [0.0, 0.0]

## Dictionary to connect objects and items
## VALUES:
	## If an item is composed of multiple tiles:
		## add endID (what is the end of this object? For tree/trunk: canopy)
	## If an object has a randRange, it means it is possible to get from
		## x to y numbers of items from it
	## Item SCENE (created in loadScenes())
	## Last item INSTANCE (created in DeleteCell())
var objectToItem = {
	## objectID: { ~end: endIndex~, 
	##  			scene: scene, 
	##  			instance: instances of objects not in the inventory }
	2: {"endID": 1, "randRange": [1, 3]}, ## trunk, end: canopy
	10: {}, ## red flower
	11: {}, ## pink flower
}
var tmpInstance

func _ready() -> void:
	## load the scenes
	loadScenes()
	## get references
	getRerefrences()

func _process(delta: float) -> void:
	## Get mouse coordinates on the screen
	mouseScreenCoords = camera.get_global_mouse_position()

## On input check for object interactions
func _input(event):
	if Input.is_action_just_pressed("mine_object") && !playerNode.attack:
		mineObject()
		playerNode.attack = true
	if Input.is_action_just_pressed("interact_with_object"):
		interact = true
	elif Input.is_action_just_released("interact_with_object"):
		interact = false
	
	# TESTING
	if Input.is_key_pressed(KEY_I): # Increase Inventory
		inventory_manager.maxSizeOfInventory = 5
		inventory_manager.maxNumOfItems = 15
	elif Input.is_key_pressed(KEY_O): # swOrd
		playerNode.equip_new_weapon("sword")
	elif Input.is_key_pressed(KEY_P): # Punch
		playerNode.equip_new_weapon("punch")


#####################
## BASIC FUNCTIONS ##
#####################

## The pickUp happens in the item_automatic_pickup.gd of each instance
func pickUp(itemID):
	if inventory_manager.isInventoryFull(itemID):
		return false
	inventory_manager.addItemToInventory(itemID, 1)
	return true

func mineObject():
	## Convert screen coordinates to tileMapLayer coordinates
	mapLayerCoords = local_to_map(mouseScreenCoords)
	
	## If there is an object on the mapCoordinates
	if (get_cell_source_id(mapLayerCoords) != -1):
		## get player position on tileMapLayer
		playerCoordsTileMapLayer = local_to_map(playerNode.get_position())
		
		if (playerCloseToObject(playerCoordsTileMapLayer, mapLayerCoords)):
			miningObjectID = get_cell_source_id(mapLayerCoords)
			if (objectToItem.has(miningObjectID)):
				miningLogic()


########################################
## Necessary priprave za začetek igre ##
########################################

## Load the scenes of the objects / items
func loadScenes():
	## ITEMS
	objectToItem[2]["scene"] = preload("res://Scenes/item_wood.tscn")
	objectToItem[10]["scene"] = preload("res://Scenes/item_redFlower.tscn")
	objectToItem[11]["scene"] = preload("res://Scenes/item_pinkFlower.tscn")

## Get references to other nodes and scripts
func getRerefrences():
	## SCRIPTS
	inventory_manager = preload("res://Scripts/player/inventory_manager.gd").new()
	player_interactions = preload("res://Scripts/player/player_interactions.gd").new()
	
	## Send the instance of THIS script to inventory_manager.gd
	inventory_manager.obj_manager = self
	playerNode.player_interactions = player_interactions
	player_interactions.player = playerNode
	player_interactions.obj_manager = self

###########
## LOGIC ##
###########

func playerCloseToObject(playerCoords, objectCoords):
	return ((objectCoords.x <= playerCoords.x + 3 && objectCoords.x >= playerCoords.x - 3) && 
			(objectCoords.y <= playerCoords.y + 3 && objectCoords.y >= playerCoords.y - 3))

func miningLogic():
	######################################################################
	## If the object exists (can drop an item), continue with mining it ##
	
	## The data I need about the cell/object being mined
	miningObjectCell = mapLayerCoords ## tilemapLayer coordinates of the object
	miningObjectCoordinates = mouseScreenCoords ## world coordinates of the object
	
	## If an object has a random range, set it, otherwise leave at 1
	var randRange: Array = [1, 1]
	if (objectToItem[miningObjectID].has("randRange")):
		randRange = objectToItem[miningObjectID]["randRange"]
	
	## Create a random number in range, of mined items
	for n in randi_range(randRange[0], randRange[1]):
		## If inventory is not full, add the item to the inventory
		if (!inventory_manager.isInventoryFull(miningObjectID)):
			inventory_manager.addItemToInventory(miningObjectID, 1)
			## Skip to the next iteration
			continue
		
		## If the inventory is full, drop the item on the floor
		createInstanceOfItem()
	
	## Then erase the mined object
	erase_cell(miningObjectCell)
	
	###############################################
	## Objects can be composed of multiple tiles ##
	
	## If the tile above it is the same object
	if (get_cell_source_id(Vector2(mapLayerCoords.x, mapLayerCoords.y - 1)) == miningObjectID):
		## then change/set the needed data for that tile (-1 and -16)
		miningObjectCoordinates.y = miningObjectCoordinates.y - 16;
		miningObjectCell = Vector2(mapLayerCoords.x, mapLayerCoords.y - 1)
		mapLayerCoords.y = mapLayerCoords.y - 1
		## and call the function again - recursive
		miningLogic()
	
	## Else if the tile above it is the end of the object, just delete it
	elif (objectToItem[miningObjectID].has("endID") && 
		  get_cell_source_id(Vector2(mapLayerCoords.x, mapLayerCoords.y - 1)) == objectToItem[miningObjectID]["endID"]):
		erase_cell(Vector2(mapLayerCoords.x, mapLayerCoords.y - 1))


## Creates an instance of an object and drops it on the floor
func createInstanceOfItem():
	## Create 2 random numbers for random drop of items (x and y)
	randNums[0] = randf_range(-20, 20)
	randNums[1] = randf_range(-20, 20)

	## Call the item scene and create an instance of it
	tmpInstance = objectToItem[miningObjectID]["scene"].instantiate()
	## Place the instance where the object was + random nums
	tmpInstance.set_position(
		Vector2(miningObjectCoordinates.x + randNums[0], 
				miningObjectCoordinates.y + randNums[1]))
	
	tmpInstance.object_manager = self
	
	## Add instance to scene
	add_child(tmpInstance)
