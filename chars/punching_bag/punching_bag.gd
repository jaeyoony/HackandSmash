extends KinematicBody2D

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
const FLOOR_NORMAL: = Vector2.UP
var velocity = Vector2.ZERO
var GRAVITY = 30
var FALL_SPEED = 750.0
var WEIGHT = 75

# default var needed by all chars 
var INPUT_KEY 
var CHAR_SPRITE_SCALE = Vector2(0.2, 0.2)

var AIR_TRACTION = 30
var FRICTION = 150
var MAX_SPEED = 350

var PERCENT = 0.0

# how many frames of hitstun remain
var hitstun_frames = 0

var hurt = preload("res://assets/punching_bag/punching_bag.png")
var idle = preload("res://assets/punching_bag/IDLE.png")

var facing = 1

export(int) var ID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# implement basic gravity so the bag just falls
func _physics_process(delta: float) -> void:
	
	velocity = calculate_move_velocity(velocity)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	if hitstun_frames:
		hitstun_frames -= 1	
		if not hitstun_frames: 
			$body/Sprite.set_texture(idle)
			$body/Sprite.set_position(Vector2.ZERO)

func calculate_move_velocity(linear_velocity:Vector2):
	var out = linear_velocity
	if out.y < FALL_SPEED: 
		out.y += GRAVITY
		out.y = min(FALL_SPEED, out.y)
		
	if not hitstun_frames: 
		if is_on_floor():
			if abs(out.x) > FRICTION:
				out.x += sign(out.x) * -1 * FRICTION
			else:
				out.x = 0
		# is airborne
		else: 
			if abs(out.x) > AIR_TRACTION:
				out.x += sign(out.x) * -1 * AIR_TRACTION
			else: 
				out.x = 0
	else: 
		if is_on_floor(): 
			if abs(out.x) > FRICTION: 
				out.x += sign(out.x) * -0.5 * FRICTION
	return out
	

# got hit by some attack
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	$body/Sprite.set_texture(hurt)
	$body/Sprite.set_position(Vector2(0,-54))
	
	var hitbox = area.owner
		
	PERCENT += hitbox.damage
#	print("Hit by: ", hitbox.player_id, "'s ", hitbox.attack_name)
	print("% : ", PERCENT)
	# calculate knockback value
	var kb = 1.4 * (((hitbox.damage+2)*(hitbox.damage+floor(PERCENT)))/20)
	kb *= (2.0 - ((2*WEIGHT/100)/(1+WEIGHT/100)))
	kb += 18
	kb *= hitbox.kb_growth/100.0
	kb += hitbox.base_knockback
	
	# set hitstun frames
	hitstun_frames = floor(kb * 0.4)
	print(kb," : ", hitstun_frames)
	# TODO: figure out a valid knockback multiplier here 
	kb *= 4
	
#	print("how to get the match's metadata: ", get_parent().owner.name)	
	
	# flip angle if necessary; remember, angle is always assumed for facing right 
	var tang = hitbox.kb_angle
	print('PB POSITION : ', position, " : ", hitbox.position)
#	if position.x < get_parent().owner.PLAYER_IDS[hitbox.player_id].position.x: 
	var comp_pos
	if hitbox.IS_PROJECTILE == true: 
		comp_pos = hitbox.position
	else: 
		comp_pos = hitbox.OWNER.position
		
	if position.x < comp_pos.x:
		if facing == -1: 
			_flip_direction(1)
		tang = 180 - tang
		
	elif position.x > comp_pos.x and facing ==  1: 
		_flip_direction(-1)
		
	tang = deg2rad(tang)

	# set velocity
	# TODO: do we add velocity here, or multiply...? or...
	velocity = Vector2(cos(tang), -sin(tang)) * kb

# when attack leaves, return to normal happy status
func _on_Hurtbox_area_exited(area: Area2D) -> void:
#	$body/Sprite.set_texture(idle)
#	$body/Sprite.set_position(Vector2.ZERO)
	return

func _flip_direction(dir): 
	if facing != dir: 
		facing = dir
		$body.set_scale(Vector2(facing,1))
		$ECB.set_scale(Vector2(facing,1))
		

