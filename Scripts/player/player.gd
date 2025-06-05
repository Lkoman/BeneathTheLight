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
@onready var object_manager: TileMapLayer = $"../ObjectsTiles"
@onready var sword_damage: Area2D = $sword_damage
@onready var punch_damage: Area2D = $punch_damage
@onready var stamina_bar: TextureProgressBar = $"../CanvasLayer/Stamina Bar"
@onready var health_bar: TextureProgressBar = $"../CanvasLayer/Health Bar"

var player_interactions

## DAMAGE
var damage := 1.0
var attack := false
var in_attack := false

## WEAPON
var weapon :String
var damageArea :Node
var all_weapons = {
	"sword": {"staminaCost": 15, "attackDamage": 20,},
	"punch": {"staminaCost": 10, "attackDamage": 5,},
}

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

## HEALTH
var _health := 100.0

var health:
	get:
		return _health
	set(value):
		_health = clamp(value, 0, 100)

## DIRECTION & ANIMATIONS
## last X or Y recorded, used for idle animations
var lastX := 0
var lastY := 0
## 1, 0, -1 for x or y
var directionX := 0
var directionY := 0
var movement := false


func _ready() -> void:
	## create the dash timer and its properties
	dashTimer = Timer.new()
	dashTimer.one_shot = true
	dashTimer.wait_time = 0.15 ## set how long the dash will last
	dashTimer.connect("timeout", _on_dashTimer_timeout)
	add_child(dashTimer)

	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	equip_new_weapon("punch")


## Moving and animations
func _physics_process(delta: float) -> void:
	stamina_bar.value = stamina
	health_bar.value = health
	
	if (in_attack):
		return
	
	if (dash):
		animated_sprite.play("dash")
	
	## if dash is false, zabeleži input from keybord for movement
	else:
		directionX = Input.get_axis("move_left", "move_right")
		directionY = Input.get_axis("move_forward", "move_backwards")
		
		animated_sprite.flip_h = false
		movement = is_movement()
		
		if (!attacking()):
			if movement:
				dashAvailable = true;
				movementAnimation()
			else:
				dashAvailable = false;
				idleAnimation()
	
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
		
	elif (!dash): ## walk
		speed = 60;
		sprint = false

func is_movement():
	return !(directionX == 0 && directionY == 0);

################
## ANIMATIONS ##
################

func movementAnimation():
	## desno (1) in levo (-1)
	if directionX == 1:
		lastX = directionX
		lastY = 0
		animated_sprite.play("walking-side")
	elif directionX == -1:
		lastX = directionX
		lastY = 0
		animated_sprite.flip_h = true
		animated_sprite.play("walking-side")
	## gor
	elif directionY == -1:
		lastY = -1
		lastX = 0
		animated_sprite.play("walking-back")
	## dol
	else:
		lastY = 1
		lastX = 0
		animated_sprite.play("walking")

func idleAnimation():
	## desno (1) in levo (-1)
	if lastX == 1:
		animated_sprite.play("idle-side")
	elif lastX == -1:
		animated_sprite.flip_h = true
		animated_sprite.play("idle-side")
	## gor
	elif lastY == -1:
		animated_sprite.play("idle-back")
	## dol
	else:
		animated_sprite.play("idle")

func _on_animation_finished():
	attack = false
	in_attack = false
	player_interactions.disable_damage_area(damageArea)

############
## ATTACK ##
############

func attacking():
	if (attack && stamina >= all_weapons[weapon]["staminaCost"]):
		stamina -= all_weapons[weapon]["staminaCost"]
		player_interactions.attack()
		var direction = player_interactions.get_attack_direction()
		
		match direction:
			"down":
				animated_sprite.play(weapon + "_attack")
			"up":
				animated_sprite.play(weapon + "_attack-back")
			"right":
				animated_sprite.play(weapon + "_attack-side")
			"left":
				animated_sprite.flip_h = true
				animated_sprite.play(weapon + "_attack-side")
		
		player_interactions.enable_damage_area(damageArea, direction)
		in_attack = true
		return 1
	return 0

func equip_new_weapon(new_weapon):
	weapon = new_weapon
	damageArea = get_node(new_weapon + "_damage")
	
	player_interactions.disable_all_damage_areas()

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
