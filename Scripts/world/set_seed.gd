extends Node
##################################################
##
##   This file generates and sets the seed
##
##################################################

## seed for the game
	## if not defined, generated in getSeed() function
var seed = null

## if the seed is inputed, hash it, otherwise select a random intiger
func getSeed():
	if (seed):
		seed = hash(seed)
	else:
		seed = randi()
	print("Using seed: ", seed)
	
func setSeed():
	seed(seed)
