extends CharacterBody2D
## Responsible for movement: moving, dashing, sprinting
## Also responsible for animations: idle, running, sprint, dashing
##
## Varibles are explained below
## Functions explained below

## SPEED & DASHING
var speed = 60.0
## this is for checking if sprint is true when finishing dashing
var sprint = false
## if dash is true, the movement input gets blocked for a while
	## until the dash completes
var dash = false
## timer for the dash to complete
var dashTimer
## dash is available if you have enough stamina and if you release
	## space in between, otherwise you could dash forever by holding space
var dashAvailable = true

## DIRECTION & ANIMATIONS
## last X or Y recorded, used for idle animations
var lastX = 0
var lastY = 0
## 1, 0, -1 for x or y
var directionX = 0
var directionY = 0

## connection to Animated Sprite for animations
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	## create the dash timer and its properties
	dashTimer = Timer.new()
	dashTimer.one_shot = true
	dashTimer.wait_time = 0.12 ## set how long the dash will last
	dashTimer.connect("timeout", _on_dashTimer_timeout)
	add_child(dashTimer)

## Moving and animations
func _physics_process(delta: float) -> void:
	## if dash is true, ignore keyboard movement input
	if (dash):
		## play the animation of dash
		animated_sprite.play("dash")
		
	## if dash is false, se zabeleži input from keybord for movement
	else:
		## Moving left, right, forward, backwards
		directionX = Input.get_axis("move_left", "move_right")
		directionY = Input.get_axis("move_forward", "move_backwards")
		animated_sprite.flip_h = false
		
		## Animations for movement
		dashAvailable = true;
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
		elif directionY == 1:
			lastY = 1
			lastX = 0
			animated_sprite.play("walking")
		elif directionY == -1:
			lastY = -1
			lastX = 0
			animated_sprite.play("walking-back")
		
		## Animation for idle
		if directionX == 0 && directionY == 0:
			dashAvailable = false;
			if lastY == -1:
				animated_sprite.play("idle-back")
			elif lastY == 1:
				animated_sprite.play("idle")
			if lastX == -1:
				animated_sprite.flip_h = true
				animated_sprite.play("idle-side")
			elif lastX == 1:
				animated_sprite.play("idle-side")
	
	## Movement for walking
	## for X (left -1 and right +1), for Y (up -1, down 1)
		## Normalize the velocty vector (to not have super fast diagonal movement)
	velocity = Vector2(directionX, directionY).normalized() * speed
	move_and_slide()

## Handle events
func _input(event):
	## if dash is not true yet, if dash is true, skip all of this
	if (!dash):
		## if dash is available and dash is pushed, you can dash
		if dashAvailable && Input.is_action_just_pressed("dash"):
			dash = true
			dashAvailable = false;
			## dash is faster if before dash was sprint true
			if (sprint):
				speed = 320;
			else:
				speed = 280;
			## when dash is activated, we start the timer
			dashTimer.start()
		## if dash is false, then speint or walk
		elif Input.is_action_pressed("sprint"):
			speed = 100;
			sprint = true
		else: ## walk
			speed = 60;
			sprint = false
	
	## if space has been released, you can dash again
	if Input.is_action_just_released("dash"):
		dashAvailable = true

## this happens when the dash timer runs out
func _on_dashTimer_timeout():
	dash = false
	## when dash is finished, return to speed before dash (sprint or walking)
	if (sprint):
		speed = 100;
	else:
		speed = 60;
