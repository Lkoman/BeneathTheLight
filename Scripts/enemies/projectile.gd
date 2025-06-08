extends Area2D

@onready var ray: RayCast2D = $RayCast2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var player

var damage := 5
var target_position :Vector2
var die_timer := Timer.new()

var exploding := false

var move_direction :Vector2

var speed := 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	die_timer.wait_time = 2.0
	die_timer.one_shot = true
	die_timer.timeout.connect(explode)
	add_child(die_timer)
	die_timer.start()
	
	move_direction = (target_position - global_position).normalized()

func _process(delta: float) -> void:
	if (!exploding):
		global_position += move_direction * speed * delta

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().name.contains("Chilli"):
		return
	
	if (area.name == "PlayerHitBox" || area.name == "EnemyHitBox"):
		area.get_parent().health -= damage
		explode()

func _on_body_entered(body: Node2D) -> void:
	if (body.name == "ObjectsTiles"):
		explode()

func explode():
	if (!exploding):
		exploding = true
		animated_sprite.play("explode")

func _on_animation_finished() -> void:
	queue_free() ## die
