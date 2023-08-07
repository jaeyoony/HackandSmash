extends Node

const PLATFORM_BIT  = 4

# how fast bill moves while in flight
const FLIGHT_SPEED = 300

# low long the move lasts
var DURATION = 45

# the angle of the launch 
var LAUNCH_ANGLE = 0

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")

func enter():
	owner.get_node("AnimationPlayer").play("UP_SPECIAL_CHARGE")
	# flip to face the correct way 
	if abs(owner.stick_buffer.back().x) and sign(owner.stick_buffer.back().x) != owner.facing: 
		owner.flip_direction(sign(owner.stick_buffer.back().x))


func state_logic(TICKER): 
	# on frame 22, enter into "flying" animation
	# note - fly has natural length of 12 frames, but can be looped 
	if TICKER < 21: 
		# adjust launch angle 
		LAUNCH_ANGLE = owner.stick_buffer.back().normalized()
#		owner.get_node("position/body/Sprite").set_rotation_degrees(rad2deg(LAUNCH_ANGLE.angle())+90
		
	elif TICKER == 21: 
		# make ledgegrab higbox larger
		owner.get_node("position/body/ledgegrab_box/ledgegrab_box_shape").shape.extents = Vector2(300, 120)
		var rotate_angle = 90
		if LAUNCH_ANGLE != Vector2.ZERO: 
			rotate_angle = round(rad2deg(LAUNCH_ANGLE.angle()))
			

		if rotate_angle < 0 and rotate_angle > -90 and owner.facing == -1: 
			owner.flip_direction(1)
		elif (rotate_angle < -90 or rotate_angle > 90) and owner.facing == 1: 
			owner.flip_direction(-1)
			
		# if we're facing one way, subtract 180 
		if owner.facing == -1: 
			# if downward angle
			if rotate_angle > 0: 
				rotate_angle = 180 - rotate_angle
			# if upward angle
			else: 
				rotate_angle = (180 + rotate_angle)*-1

		rotate_angle += 45
		
		owner.get_node("position/body/Sprite").set_rotation_degrees(rotate_angle)
		owner.get_node("AnimationPlayer").play("UP_SPECIAL_FLY")
		# turn off platform collision
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
	
# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	# slow down to 0 in both horizontal and vertical speeds 
	var out = curr_vel
	if TICKER < 21: 
		if out != Vector2.ZERO: 
			out *= 0.88
		return out
	else: 
		# default launch vector
		if LAUNCH_ANGLE == Vector2.ZERO: 
			LAUNCH_ANGLE = Vector2(0, -1)
		# set out velocity to launch angle * some set speed
		out = LAUNCH_ANGLE * FLIGHT_SPEED
	return out


func exit(): 
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	owner.get_node("position/body/Sprite").set_rotation_degrees(0)
	owner.get_node("position/body/ledgegrab_box/ledgegrab_box_shape").shape.extents = Vector2(161.489, 87.673)
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

