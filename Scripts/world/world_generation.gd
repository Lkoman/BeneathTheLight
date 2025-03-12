extends Node
##################################################
##
##   This file creates the world map and object map 
##   and fills them
##
##################################################

## Map of mineable objects
	## 1-9 trees (1 green tree, 2 orange tree)
	## 10-19 rocks (10 small rock)
	## 20-29 flowers (20 pink flower, 21 red flower)
var objectMap: Array = []
## width and length of table - size (vedno kvadratno)
const objectMapSize: int = 50


## CREATE OBJECT MAP AND FILL IT
	## Using ranf for randomness
func createObjectMap():
	## Create the map, populate it with randf
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
