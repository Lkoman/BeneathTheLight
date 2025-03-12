extends Node
#########################################################
##
## This file is responsible for managing the inventory
## It communicates with object_tiles.gd
##
#########################################################

## Inventory dictionary of dictionaries
	## ItemID == objectID in itemToObject dictionary in file object_tiles.gd
var INVENTORY = {
	## itemID: { stacks: [numOfObjects, numOfObjects, ...], scene: scene}
}

## The size of stacks in the inventory
var inventorySize: int = 0

## The max size of unique items in the inventory
var maxSizeOfInventory: int = 5
var maxNumOfItems: int = 15

## References
var objTiles ## get instance of object_tiles from object_tiles.gd


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func addItemToInventory(itemID, scene, numOfItems):
	## If item does not exist in the inventory, create it
	if (!INVENTORY.has(itemID)):
		INVENTORY[itemID] = {}
		INVENTORY[itemID]["stacks"] = []
		INVENTORY[itemID]["scene"] = scene
		
		## Create new item stack
		createNewItemStack(itemID, numOfItems)
		
		print(INVENTORY)
		print("size: ", inventorySize)
		
		return
	
	#########################################
	## IF THE ITEM EXISTS IN THE INVENTORY ##
	
	## If last stack is full, create a new stack
	if (INVENTORY[itemID]["stacks"].back() == maxNumOfItems):
		createNewItemStack(itemID, numOfItems)
	
	## Else if last element in stacks + numOfItems is smaller than
	## or equal to maxNumOfItems, add the items to the last stack
	elif (INVENTORY[itemID]["stacks"].back() + numOfItems <= maxNumOfItems):
		INVENTORY[itemID]["stacks"][INVENTORY[itemID]["stacks"].size() - 1] += numOfItems
	
	## If some items can go to the last stack, but not all of them
	## fill the last stack, and create a new stack with remaining items
	else:
		var dodam: int = maxNumOfItems - INVENTORY[itemID]["stacks"].back()
		var nextStack: int = numOfItems - dodam
		
		## Fill the last stack kolikor gre
		INVENTORY[itemID]["stacks"][INVENTORY[itemID]["stacks"].size() - 1] += dodam
		
		## Create a new stack with nextStack number of items
		createNewItemStack(itemID, nextStack)
	
	print(INVENTORY)
	print("size: ", inventorySize)


func createNewItemStack(itemID, numOfItems):
	## If numOfItems <= maxNumOfItems we can add them all to one stack
	if (numOfItems <= maxNumOfItems):
		INVENTORY[itemID]["stacks"].append(numOfItems)
		inventorySize += 1
	
	## If numOfItems is too big, we have to make multiple stacks
	else:
		## Get number of full stacks and ostanek
		var numOfStacks: int = numOfItems / maxNumOfItems
		var ostanek: int =  numOfItems % maxNumOfItems
		
		## create numOfStacks numbers of full stacks
		for n in numOfStacks:
			INVENTORY[itemID]["stacks"].append(maxNumOfItems)
			inventorySize += 1
		
		## if there is any ostanek, create a new stack with that many items
		if (ostanek > 0):
			INVENTORY[itemID]["stacks"].append(ostanek)
			inventorySize += 1


func isInventoryFull(itemID):
	## Če je inventorySize manjši od maxSizeOfInventory vedno returna true
	if (inventorySize < maxSizeOfInventory):
		return false
	
	## Če ima inventory v sebi item, ki ga želimo mine-at
	## in če ima vsaj eden od stackov numOfItems < maxNumOfIrems
	## potem ima inventory še prostora
	if (INVENTORY.has(itemID)):
		for stack in INVENTORY[itemID]["stacks"]:
			if (stack < maxNumOfItems):
				return false
	
	## Če nič od tega ni res, potem je inventory poln
	return true
