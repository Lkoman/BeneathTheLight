extends CharacterBody2D
#############################################################
##
## Responsible for movement: moving, dashing, sprinting
## Also responsible for animations: idle, running, sprint, dashing
##
## Varibles are explained below
## Functions explained below
##
##############################################################

## REFERENCES
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## DAMAGE
var damage := 1.0

## SPEED
var speed := 60.0
var sprint := false
var sprintAvailable := true

## DASH
var dash := false
var dashAvailable := true
var dashTimer: Timer ## timer for the dash to complete

## STAMINA
var _stamina := 100.0

var stamina:
	get:
		return _stamina
	set(value):
		_stamina = clamp(value, 0, 100)

var sprintStaminaCost := 10.0 ## per frame
var dashStaminaCost := 18.0 ## per dash
var staminaRegeneration := 15.0 ## per frame

## DIRECTION & ANIMATIONS
## last X or Y recorded, used for idle animations
var lastX := 0
var lastY := 0
## 1, 0, -1 for x or y
var directionX := 0
var directionY := 0


func _ready() -> void:
	## create the dash timer and its properties
	dashTimer = Timer.new()
	dashTimer.one_shot = true
	dashTimer.wait_time = 0.12 ## set how long the dash will last
	dashTimer.connect("timeout", _on_dashTimer_timeout)
	add_child(dashTimer)


## Moving and animations
func _physics_process(delta: float) -> void:
	if (dash):
		animated_sprite.play("dash")
	
	## if dash is false, zabeleži input from keybord for movement
	else:
		directionX = Input.get_axis("move_left", "move_right")
		directionY = Input.get_axis("move_forward", "move_backwards")
		animated_sprite.flip_h = false
		
		if directionX == 0 && directionY == 0: ## no movement
			dashAvailable = false;
			idleAnimation()
		else:
			dashAvailable = true;
			movementAnimation()
	
	## STAMINA
	if (sprint):
		stamina -= sprintStaminaCost * delta
	else:
		stamina += staminaRegeneration * delta
	
	# print("stamina: ", stamina)
	
	## MOVE
	velocity = Vector2(directionX, directionY).normalized() * speed
	move_and_slide()


## Handle events
func _input(event):
	if Input.is_action_just_released("dash"):
		dashAvailable = true
	
	if Input.is_action_just_released("sprint"):
		sprintAvailable = true
	
	if (Input.is_action_just_pressed("dash") && canDash()):
		dash = true
		dashAvailable = false;
		dashTimer.start()
		stamina -= dashStaminaCost
		
		if (sprint):
			speed = 320;
			dashStaminaCost = 22.0
		else:
			speed = 280;
			dashStaminaCost = 18.0
		
	elif (Input.is_action_pressed("sprint") && canSprint()):
		speed = 100;
		sprint = true
		
	else: ## walk
		speed = 60;
		sprint = false


################
## ANIMATIONS ##
################

func movementAnimation():
	## desno
	if directionX == 1:
		lastX = 1
		lastY = 0
		animated_sprite.play("walking-side")
	## levo
	elif directionX == -1:
		lastX = -1
		lastY = 0
		animated_sprite.flip_h = true
		animated_sprite.play("walking-side")
	## dol
	elif directionY == 1:
		lastY = 1
		lastX = 0
		animated_sprite.play("walking")
	## gor
	elif directionY == -1:
		lastY = -1
		lastX = 0
		animated_sprite.play("walking-back")

func idleAnimation():
	if lastY == -1:
		animated_sprite.play("idle-back")
	elif lastY == 1:
		animated_sprite.play("idle")
	if lastX == -1:
		animated_sprite.flip_h = true
		animated_sprite.play("idle-side")
	elif lastX == 1:
		animated_sprite.play("idle-side")

##########
## DASH ##
##########

func _on_dashTimer_timeout():
	dash = false
	## when dash is finished, return to speed before dash (sprint or walking)
	if (sprint):
		speed = 100;
	else:
		speed = 60;

func canDash():
	return !dash && dashAvailable && stamina >= dashStaminaCost;

func canSprint():
	if (sprintAvailable && stamina >= sprintStaminaCost):
		return true;
	
	sprintAvailable = false
	sprint = false
	return false;
