extends Node

#################################################################
##
## This file is responsible for player interactions, such as:
## - attack
##
##
## - mining is in file objects_manager.gd and player.gd because it manipulates
##   the tileMapLayer ObjectsTiles
##
#################################################################

## REFERENCES to other nodes and scripts used in this script
var player: Node
var obj_manager: Node

## VARIABLES


func attack():
	var direction = obj_manager.mouseScreenCoords - player.get_position()
	var angle_radians = direction.angle()
	
	if player.damageArea.name == "punch":
		player.damageArea.rotation = angle_radians

func disable_all_damage_areas():
	for weapon in player.all_weapons:
		var damage_area = player.get_node(weapon)
		disable_damage_area(damage_area)

func enable_damage_area(damage_area, direction):
	var damage_sprite
	if (damage_area.get_node("AnimatedSprite2D")):
		damage_sprite = damage_area.get_node("AnimatedSprite2D")
		damage_sprite.play("particles")
		## Play animation
		if (direction == "down" || direction == "left"):
			damage_sprite.flip_v = true
		else:
			damage_sprite.flip_v = false
	else:
		damage_sprite = damage_area.get_node("Sprite2D")
		damage_sprite.flip_v = false
		damage_sprite.flip_h = false
		
		if direction == "right":
			damage_area.position.x = 5
			damage_area.position.y = -4
			damage_area.rotation_degrees = 33
		elif direction == "left":
			damage_area.position.x = -5
			damage_area.position.y = -4
			damage_area.rotation_degrees = -33
		elif direction == "up":
			damage_area.position.x = 2
			damage_area.position.y = -2
			damage_area.rotation_degrees = 33
		elif direction == "down":
			damage_area.position.x = -2
			damage_area.position.y = -2
			damage_area.rotation_degrees = -33
	
	damage_area.monitoring = true
	damage_area.get_node("CollisionShape2D").disabled = false
	
	damage_sprite.visible = true

func disable_damage_area(damage_area):
	damage_area.monitoring = false
	var damage_sprite
	
	if (damage_area.get_node("AnimatedSprite2D")):
		damage_sprite = damage_area.get_node("AnimatedSprite2D")
	else:
		damage_sprite = damage_area.get_node("Sprite2D")
		
	damage_sprite.visible = false
	damage_area.get_node("CollisionShape2D").disabled = true

func get_attack_direction():
	var direction = obj_manager.mouseScreenCoords - player.global_position
	var angle = direction.angle() * 180 / PI
	
	# Normalize angle between -180 and 180
	angle = fposmod(angle + 180, 360) - 180

	if angle >= -45 and angle <= 45:
		return "right"
	elif angle > 45 and angle < 135:
		return "down"
	elif angle <= -45 and angle > -135:
		return "up"
	else:
		return "left"
