extends Area2D

## References
var object_manager
@onready var sprite: Sprite2D = $Sprite2D

var itemID
var pickupable = false


func _ready():
	var texture = sprite.texture
	if texture:
		itemID = int(texture.resource_path.get_file().split("_")[0])

func _process(delta: float) -> void:
	if (pickupable):
		if (object_manager.pickUp(itemID)):
			deleteItem()


func _on_body_entered(body: Node2D) -> void:
	if (body is CharacterBody2D):
		pickupable = true

func _on_body_exited(body: Node2D) -> void:
	if (body is CharacterBody2D):
		pickupable = false

func deleteItem():
	queue_free()
