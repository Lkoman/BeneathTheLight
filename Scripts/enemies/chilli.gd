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

var stamina_regeneration := 2.0 ## per frame

## ATTACK
var in_attack := false

## PROJECTILE
var projectile_scene
var projectile_timer = Timer.new()
var tmp_projectile_instance
var projectile_stamina_cost := 5.0

var target_position: Vector2
var spawn_position :Vector2

func _ready() -> void:
	health_bar.max_value = health
	stamina_bar.max_value = stamina
	
	load_scenes()
	
	projectile_timer.wait_time = randf_range(0, 3)
	projectile_timer.one_shot = false
	projectile_timer.timeout.connect(create_new_projectile)
	add_child(projectile_timer)

func _physics_process(delta: float) -> void:
	if (in_attack):
		animation.play("attack")
	else:
		health += health_regeneration_idle * delta
		animation.play("idle")
	
	stamina += stamina_regeneration * delta
	
	health_bar.value = health
	stamina_bar.value = stamina

func _on_fov_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body && body.name == "Player":
		in_attack = true;
		create_new_projectile()
		projectile_timer.start()

func _on_fov_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body && body.name == "Player":
		in_attack = false;
		projectile_timer.stop()

func _on_hit_box_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if "_damage" in area.name:
		health -= player.all_weapons[player.weapon]["attackDamage"]
		
		if (health <= 0):
			enemies_manager.die(self)

func create_new_projectile():
	projectile_timer.wait_time = randf_range(0, 3)
	if (stamina - projectile_stamina_cost >= 0):
		stamina -= projectile_stamina_cost
		target_position = player.position

		tmp_projectile_instance = projectile_scene.instantiate()
		tmp_projectile_instance.target_position = player.position
		tmp_projectile_instance.player = player
		## starting position is the position of the parent
		add_child(tmp_projectile_instance)

func load_scenes():
	projectile_scene = load("res://Scenes/Enemies/projectile-red.tscn")
