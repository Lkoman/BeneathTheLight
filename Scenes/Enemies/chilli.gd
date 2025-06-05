extends Area2D

@onready var health: TextureProgressBar = $Health

var hp := 30
var attack_damage := 30
var player: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.max_value = hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health.value = hp

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player.health -= attack_damage

func _on_area_entered(area: Area2D) -> void:
	hp -= player.all_weapons[player.weapon]["attackDamage"]
	
	if (hp <= 0):
		die()

func die():
	queue_free()
