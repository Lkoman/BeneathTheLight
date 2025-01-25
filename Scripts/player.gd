extends CharacterBody2D

# walking / running speed
const SPEED = 130.0

# last X or Y recorded, used for idle animations
var lastX = 0
var lastY = 0

# connection to Animated Sprite for animations
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Moving and animations
func _physics_process(delta: float) -> void:
	
	# Moving left, right, forward, backwards
	var directionX := Input.get_axis("move_left", "move_right")
	var directionY := Input.get_axis("move_forward", "move_backwards")
	animated_sprite.flip_h = false
	
	# Movement for walking
	# for X (left -1 and right +1)
	if directionX:
		velocity.x = directionX * SPEED
	else: # else stop moving in x direction
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# for Y (up -1, down 1)
	if directionY:
		velocity.y = directionY * SPEED
	else: # else stop moving in y direction
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Animations for movement
	if directionY == 1:
		lastY = 1
		lastX = 0
		animated_sprite.play("walking")
	elif directionY == -1:
		lastY = -1
		lastX = 0
		animated_sprite.play("walking-back")
	if directionX == 1:
		lastX = 1
		lastY = 0
		animated_sprite.flip_h = false
		animated_sprite.play("walking-side")
	elif directionX == -1:
		lastX = -1
		lastY = 0
		animated_sprite.flip_h = true
		animated_sprite.play("walking-side")
	
	# Animation for idle
	if directionX == 0 && directionY == 0:
		if lastY == -1:
			animated_sprite.play("idle-back")
		elif lastY == 1:
			animated_sprite.play("idle")
		if lastX == -1:
			animated_sprite.flip_h = true
			animated_sprite.play("idle-side")
		elif lastX == 1:
			animated_sprite.play("idle-side")

	move_and_slide()
