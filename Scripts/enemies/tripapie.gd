extends Area2D

@onready var health: TextureProgressBar = $Health

var hp := 80
var attack_damage := 10
var player: Node

var speed := 10
var target_position: Vector2

var changeDirTimer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.max_value = hp
	target_position = Vector2(randi_range(-100, 100), randi_range(-100, 100))
	
	changeDirTimer.wait_time = 1.0
	changeDirTimer.one_shot = false
	changeDirTimer.timeout.connect(_change_direction)
	add_child(changeDirTimer)
	changeDirTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	health.value = hp
	position = position.move_toward(target_position, speed * delta)

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player.health -= attack_damage

func _on_area_entered(area: Area2D) -> void:
	hp -= player.all_weapons[player.weapon]["attackDamage"]
	
	if (hp <= 0):
		die()

func die():
	queue_free()

func _change_direction():
	speed = randi_range(0, 30)
	target_position = Vector2(randi_range(-100, 100), randi_range(-100.0, 100.0))
	changeDirTimer.wait_time = randf_range(0.1, 10.0)
