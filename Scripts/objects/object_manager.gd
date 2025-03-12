extends TileMapLayer
#################################################
##
##   This file is responsible for object mining
##   and placing objects on the tileMapLayer
##
#################################################

## References to other nodes
@onready var camera: Camera2D = $"../Player/Camera2D"

var isMining: bool = false
var miningObject: String

var worldMouseCoordinates = null ## save the coordinates of the mouse
var mapCoordinates = null ## tileMapLayer coordinates

func object(object):
	if (isMining == false):
		miningObject = object
		print(miningObject)
		isMining = true
