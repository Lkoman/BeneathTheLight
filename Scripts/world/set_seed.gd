extends Node
##################################################
##
##   This file generates and sets the seed
##
##################################################

var seed = null

func getSeed():
	if (seed):
		seed = hash(seed)
	else:
		seed = randi()
	print("Using seed: ", seed)
	
func setSeed():
	seed(seed)
