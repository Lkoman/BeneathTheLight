extends Area2D

@onready var health: TextureProgressBar = $Health
var player: Node

## HEALTH
var _hp := 80.0

var hp:
	get:
		return _hp
	set(value):
		_hp = clamp(value, 0, 80)

var hp_regeneration_idle := 0.5 ## per frame

var attack_damage := 10
var speed := 10
var in_attack := false

var spawn_position: Vector2
var target_position: Vector2
var change_dir_timer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health.max_value = hp
	target_position = new_rand_vector()
	
	change_dir_timer.wait_time = 2.0
	change_dir_timer.one_shot = false
	change_dir_timer.timeout.connect(change_direction)
	add_child(change_dir_timer)
	change_dir_timer.start()

func _process(delta: float) -> void:
	if (in_attack):
		target_position = player.position
	else:
		hp += hp_regeneration_idle * delta
	
	health.value = hp
	position = position.move_toward(target_position, speed * delta)

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body.name == "Player"):
		if local_shape_index == 0: ## HitBox
			player.health -= attack_damage
		elif local_shape_index == 1: ## Field Of View
			in_attack = true;
			speed = randi_range(30, 60)

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body.name == "Player") && local_shape_index == 1: ## Field Of View
		in_attack = false;

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if "_damage" in area.name && is_area_hitbox(local_shape_index): ## HitBox
		hp -= player.all_weapons[player.weapon]["attackDamage"]
	
		if (hp <= 0):
			die()

func die():
	queue_free()

func is_area_hitbox(shape_index):
	return shape_index == 0

func new_rand_vector():
	return Vector2(randi_range(spawn_position.x - 100, spawn_position.x + 100), 
				   randi_range(spawn_position.y - 100, spawn_position.y + 100))

func change_direction():
	if (!in_attack):
		speed = randi_range(0, 30)
		target_position = new_rand_vector()
		change_dir_timer.wait_time = randf_range(0.1, 10.0)
