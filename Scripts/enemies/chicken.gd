extends CharacterBody2D

## REFERENCES
var player: Node
var enemies_manager: Node

@onready var health_bar: TextureProgressBar = $Health
@onready var stamina_bar: TextureProgressBar = $Stamina
@onready var field_of_view: CollisionShape2D = $FovArea/FieldOfView
@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

## HEALTH
var _health := 80.0

var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, 80)

var health_regeneration_idle := 0.5 ## per frame

## STAMINA
var _stamina := 80.0

var stamina:
	get:
		return _stamina
	set(value):
		_stamina = clamp(value, 0, 80)

var stamina_regeneration := 5.0 ## per frame

## KLJUV ATTACK
var kljuv_attack_damage := 5
var in_attack := false
var kljuv_attack_stamina_cost := 15

## CIRCLE
var circle_num := 0

## MOVING
var speed := 10
var spawn_position: Vector2
var spawn_offset := 100.0
var target_position: Vector2
var change_dir_timer = Timer.new()

func _ready() -> void:
	health_bar.max_value = health
	stamina_bar.max_value = stamina
	target_position = enemies_manager.new_rand_vector_around_spawn(spawn_position, spawn_offset)
	
	create_direction_timer()

func _physics_process(delta: float) -> void:
	if (in_attack):
		animation.speed_scale = 2.0
		
		if position.distance_to(target_position) < 5:
			if (circle_num >= 1):
				circle_player()
				circle_num -= 1
			else:
				kljuv_attack()
	
	else: ## idle (not attacking)
		animation.speed_scale = 1.0
		health += health_regeneration_idle * delta
	
	stamina += stamina_regeneration * delta
	
	health_bar.value = health
	stamina_bar.value = stamina
	var motion = (target_position - position).normalized() * speed * delta
	var collision = move_and_collide(motion)

	if collision:
		if (randf() < 0.5):
			kljuv_attack()
		else:
			retreat(20)

func _on_fov_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body && body.name == "Player":
		kljuv_attack()

func _on_fov_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body && body.name == "Player":
		in_attack = false;
		change_direction()

func _on_kljun_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area && "_damage" in area.name:
		health -= player.all_weapons[player.weapon]["attackDamage"]
	
		if (health <= 0):
			enemies_manager.die(self)

func _on_kljun_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body && body.name == "Player":
		body.health -= kljuv_attack_damage
		retreat(20)

func kljuv_attack():
	if (stamina - kljuv_attack_stamina_cost >= 0):
		speed = randi_range(60, 80)
		stamina -= kljuv_attack_stamina_cost
		in_attack = true;
		target_position = player.position
		circle_num = randi_range (0, 3)
	else:
		circle_num = randi_range (2, 6)
		circle_player()

func circle_player():
	speed = randi_range(50, 60)
	var shape := field_of_view.shape as CircleShape2D
	var min_radius = shape.radius * 0.33
	var max_radius = shape.radius * 0.5
	var circle_distance = randf_range(min_radius, max_radius)

	# Vector from enemy to player
	var to_player = player.global_position - global_position
	var perpendicular = to_player.orthogonal().normalized()

	# Randomly choose left or right
	var direction
	if (randf() < 0.5):
		direction = -perpendicular
	else:
		direction = perpendicular

	# Target position: offset sideways from the player
	var offset = direction * circle_distance
	target_position = player.global_position + offset
	
	in_attack = true

func retreat(retreat_offset):
	var shape := field_of_view.shape as CircleShape2D
	var retreat_radius := shape.radius - randi_range(retreat_offset, shape.radius - retreat_offset)

	# Step 1: Direction away from player
	var away_vector = (global_position - player.global_position).normalized()

	# Step 2: Add random angle variation (±45 degrees in radians)
	var angle_offset = deg_to_rad(randf_range(-80.0, 80.0))
	var retreat_direction = away_vector.rotated(angle_offset)

	# Step 3: Apply offset
	var offset = retreat_direction * retreat_radius
	target_position = global_position + offset
	
	in_attack = true

func change_direction():
	if (!in_attack):
		speed = randi_range(0, 30)
		target_position = enemies_manager.new_rand_vector_around_spawn(spawn_position, spawn_offset)
		change_dir_timer.wait_time = randf_range(0.1, 10.0)

func create_direction_timer():
	change_dir_timer.wait_time = 2.0
	change_dir_timer.one_shot = false
	change_dir_timer.timeout.connect(change_direction)
	add_child(change_dir_timer)
	change_dir_timer.start()
