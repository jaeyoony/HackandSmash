extends KinematicBody2D
const FLOOR_NORMAL: = Vector2.UP

const CHAR_SPRITE_SCALE = Vector2(0.07, 0.07)

# hitspark generator import 
const HITSPARK_GENERATOR = preload("res://assets/effects/hitspark_generator.tscn")

# hitbox scene preload 
const HITBOX_SCENE = preload("res://hboxes/hitbox.tscn")

# projectile scene preload
const PROJECTILE_SCENE = preload("res://chars/bongo_bill/bullet/bullet.tscn")

# characters ground movement properties 
const SPEED = 25
const BASE_RUN_ACCEL = 10
const ADD_RUN_ACCEL = 15
const JUMP_FORCE = 310
const FRICTION = 8
const RUN_SPEED = 230.0
const BASE_WALK_ACCEL = 7
const ADD_WALK_ACCEL = 10
const WALK_SPEED = 85
const DASH_SPEED = 200

# Characters air movement properties
const AIR_ACCEL = 6
const BASE_AIR_ACCEL = 2
const ADD_AIR_ACCEL = 4
const MAX_AIR_SPEED = 112.0
const AIR_TRACTION = 1
const FALL_SPEED = 290
const FASTFALL_SPEED = 350
const GRAVITY = 13
const AIRDODGE_SPEED = 350

# shield variables - originally 80
const SHIELD_MAX_HP = 80.0
var SHIELD_HP: = 80.0

# CONTROLLER THRESHOLDS 
# NOTE : using 0.65 as the dash thresh
# so zones look like this: 
# 0.00 - 0.10 : deadzone
# 0.10 - 0.60 : walk
# 0.60 - 0.8 : slow run / non-smash
# 0.80 - 1.0 : fast run / smash input
const dash_thr = 0.6
const walk_thr = 0.1
const smash_thr = 0.8

# keeps track of the last THREE left stick inputs from the controller
var stick_buffer = [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO, Vector2.ZERO]
 

# all ID's of players hit from the last attack
# cleared on exiting ground/air attack state, or hitstun state
#	key:val  =  ID of player hit : Priority level of hitbox hit by 
var has_hit = {}

# set ID in the metagame, somehow..? 
export(int) var ID
const WEIGHT = 300

# character's current velocity
var velocity: = Vector2.ZERO
# flag for airborne state
var AIRBORNE = false

# track the number of jumps char has avaliable + if they're currently fastfalling
var MAX_JUMPS = 2
var jumps = 2
var fastfalling = false
var TUMBLING = false
# whether they've aidodged 
var AIRDODGE_AVAILABLE = false

# keeps track of current hitlag frames remaining
# remember: hitLAG = frames of lag the ATTACKER experiences after landing a move
var HITLAG_FRAMES = 0
var HITLAG_VELOCITY = Vector2.ZERO

# character's current HP and shield HP
export var PERCENT = 0.0

# keep track of the current and just prior state 
# note: curr_state = actual node in state machine
# 		prev_state = (string) name of the state
var curr_state = null
var prev_state = "IDLE"
# dict to store state names : node references
var states_map = null

# deferred hitbox node, for block-attack case
var DEFERRED_HITBOX = null
# deferred hitbox priority, default to -1
# use to quickly compare new hitboxes to deferred hitbox (see if deferred needs to be replaced) 
var DEFERRED_PRIORITY = -1

# keep track of direction sprite is facing: 1 == facing right, -1 == facing left
export var facing = 1

# RNG caller 
var rng = RandomNumberGenerator.new()

# TESTING VARS 
var curr_anim = null
var last_input = Vector2.ZERO
var last_state_name = null

# if true, then remove all input for character (so it just stands still)
var dummy_mode = false
var dummy_shield_mode = false
# dummy states are the states that the char is not allowed to enter in dummy mode
const bad_dummy_states = ['AIR_ATTACK', 'GROUND_ATTACK', 'SPECIAL_ATTACK', 'JUMP_SQUAT', 'BLOCK', 'DOUBLE_JUMP', 'GRAB']

var INV_FLAG = 0

# input key to attatch to the end of input checks
# defaults to player 1 
var INPUT_KEY = '_p1'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set ID
	states_map = {
		"IDLE": $States/IDLE,
		"WALK": $States/WALK,
		"CROUCH": $States/CROUCH, 
		"CROUCH_SQUAT": $States/CROUCH_SQUAT,
		"JUMP_SQUAT": $States/JUMP_SQUAT, 
		"JUMP": $States/JUMP, 
		"DOUBLE_JUMP": $States/DOUBLE_JUMP,
		"FALL": $States/FALL,
		"LAND": $States/LAND, 
		"DASH": $States/DASH, 
		"DASH_TURN": $States/DASH_TURN,
		"RUN": $States/RUN, 
		"RUN_STOP": $States/RUN_STOP, 
		"GROUND_ATTACK": $States/GROUND_ATTACK, 
		"AIR_ATTACK": $States/AIR_ATTACK,
		"SPECIAL_ATTACK": $States/SPECIAL_ATTACK,
		"HITFREEZE": $States/HITFREEZE, 
		"HITSTUN": $States/HITSTUN,
		"AIRDODGE": $States/AIRDODGE, 
		"BLOCK": $States/BLOCK,
		"ROLL": $States/ROLL, 
		"TUMBLE": $States/TUMBLE,
		"LEDGE_HANG": $States/LEDGE_HANG,
		"FREEFALL": $States/FREEFALL,
		"GRAB": $States/GRAB, 
		"GRABBED_STATE": $States/GRABBED_STATE,
		"TECH": $States/TECH, 
		"KNOCKDOWN": $States/KNOCKDOWN,
	}
	curr_state = get_node("States/IDLE")
	curr_state.enter()
	$position/body.set_scale(Vector2(facing, 1))
	
	# attach hitspark generator
	$position/body.add_child(HITSPARK_GENERATOR.instance(), true)
	# set initial shield size
	$position/body/shield/shield_shape.shape.radius = SHIELD_HP*3.125

func _physics_process(delta: float) -> void:
	# check for deferred_hitbox, and if shield has also it
	# DEFERRED HITBOX is a way to check if shield and hurtbox got hit on the same frame, 
	#	accounting for the fact that one will not always get hit after the other 
	#	(random which will get hit first) 
	if DEFERRED_HITBOX: 
		if DEFERRED_HITBOX.IS_GRAB: 
			_get_grabbed(DEFERRED_HITBOX)
		# check that the owner did indeed hit us 
		elif !DEFERRED_HITBOX.IS_PROJECTILE and not DEFERRED_HITBOX.get_parent().owner.has_hit.has(ID): 
			_get_hit(DEFERRED_HITBOX)
		elif DEFERRED_HITBOX.IS_PROJECTILE: 
			_get_hit(DEFERRED_HITBOX)
		else: 
			DEFERRED_HITBOX = null
	
	if INV_FLAG: 
		INV_FLAG -= 1
		if not INV_FLAG: 
			_enable_hurtboxes()

	
	# let states do their per/frame thing 
	curr_state.state_logic(delta)
	var dir = read_input()
	
#	# DEBUG: store last input direction 
#	if dir != last_input: 
#		last_input = dir
#
	# DEBUG: print states 
	if last_state_name != curr_state.name and not (dummy_mode or dummy_shield_mode): 
		print(curr_state.name)
		last_state_name = curr_state.name

	#DEBUG: print current animation 
#	if $AnimationPlayer.get_current_animation() != curr_anim: 
#		print("current animation: ", $AnimationPlayer.get_current_animation())
#	curr_anim = $AnimationPlayer.get_current_animation()



	velocity = calculate_move_velocity(velocity, dir, curr_state)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	

	# set correct ECB 
	if is_on_floor() and AIRBORNE: # just landed
		AIRBORNE = false
		$ECB.disabled = false
#		$AIR_ECB.disabled = true
	# check that changing ECB will not automatically cause clipping when switching
	elif !is_on_floor() and not AIRBORNE: # just ungrounded
		AIRBORNE = true
		$ECB.disabled = true
#		$AIR_ECB.disabled = false
	
	# check for state change 
	change_state(curr_state.check_state())
	
	# add shield HP if not blocking/rolling
	if (curr_state.name != "BLOCK" and curr_state.name!='ROLL') and SHIELD_HP < SHIELD_MAX_HP: 
		SHIELD_HP = min(SHIELD_MAX_HP, SHIELD_HP+0.3)


# read the input, returns the unit vector of the direction held on left stick
func read_input(): 
	# NOTE : for y input, -1 == UP and 1 == DOWN
	var out = Vector2(
		Input.get_action_strength("move_right"+INPUT_KEY) - Input.get_action_strength("move_left"+INPUT_KEY),
		-Input.get_action_strength("stick_up"+INPUT_KEY) + Input.get_action_strength("crouch"+INPUT_KEY)
	)
	
	if dummy_mode: 
		out = Vector2.ZERO
	
	# normalize according to stick calibration... 
	# FOR SWITCH: divide by 0.73
#	if Input.get_joy_name(0) != "":
#		out.x /= 0.7
#		out.y /= 0.7
		
	# deadzone check
	if out.length() < 0.1: 
		out = Vector2.ZERO

	if Input.is_action_pressed("walk_key"): 
		out *= 0.5
	
	# handle the input
	# add input to input buffer
	out = curr_state.process_input(out)
	stick_buffer.pop_front()
	stick_buffer.push_back(out)
	
	# debug
	return out


# reads input from second stick (right stick) to determine which direction was input
#	returns either: RIGHT (1,0), LEFT (-1,0), DOWN (0,1), UP (0,-1) or VOID 
func _read_stick2(): 
	# stick2_out = the output from the controller's right stick
	var out2 = Vector2(
		Input.get_action_strength("stick2_right") - Input.get_action_strength("stick2_left"), 
		-Input.get_action_strength("stick2_up") + Input.get_action_strength("stick2_down")
	)
	
	if out2.length() > walk_thr: 
		return out2
		
	return Vector2.ZERO
	
	# normalize according to stick calibration... 
	# FOR SWITCH: divide by 0.73
	
	# return a cardinal direction	
#	if abs(out2.x) > abs(out2.y) and abs(out2.x) > 0.1: 
#		return Vector2(sign(out2.x), 0)
#	elif abs(out2.y) > abs(out2.x) and abs(out2.y) > 0.1: 
#		return Vector2(0, sign(out2.y))
#	return Vector2.ZERO


# calculates the new velocity of the character on next frame, using
#	character's current vel, their speed, and the most recent inputs (direction)
func calculate_move_velocity(
		linear_velocity:Vector2, 
		direction: Vector2, 
		curr_state
	) -> Vector2: 
		
	# the current velocity of character 
	var out: = linear_velocity
	
	# special state conditions
	if HITLAG_FRAMES:
		HITLAG_FRAMES-=1
		# check for exiting hitlag
		if HITLAG_FRAMES == 0: 
			var temp = HITLAG_VELOCITY
			HITLAG_VELOCITY = Vector2.ZERO
			$AnimationPlayer.play()
			return temp
			
		return Vector2.ZERO

	
	if curr_state.name == "RUN_STOP": 
		direction.x = 0
	
	elif curr_state.name == "ROLL" or curr_state.name == 'TECH':
		return curr_state.calculate_velocity(direction, out)
		
	elif curr_state.name == "HITFREEZE" or curr_state.name == 'LEDGE_HANG': 
		return Vector2.ZERO
	
	# if in hitstun, can move faster 
	elif curr_state.name == "HITSTUN" or curr_state.name == 'TUMBLE': 
		print(out.y)
		if abs(out.x) > 5: 
			out.x -= 4 * sign(out.x)
		if out.y < FALL_SPEED: 
			out.y += 20
		return out 
		
	elif curr_state.name == "SPECIAL_ATTACK" and (curr_state.CURRENT_ATTACK.name == "UP" or curr_state.CURRENT_ATTACK.name == "SIDE"): 
		return curr_state.calculate_velocity(direction, linear_velocity)
	
	# ULTIMATE airdodge : gives quick burst of speed and then momentum carries 
	elif curr_state.name == "AIRDODGE" and curr_state.TICKER < 10: 
		return curr_state.calculate_velocity(direction, linear_velocity)
	
	elif curr_state.name == "GRAB" or curr_state.name =='GRABBED_STATE': 
		return curr_state.calculate_velocity(direction, linear_velocity)
	
	if is_on_floor(): 
		# mid dash dance, set velocity to 0
		if curr_state.name == "DASH_TURN": 
			out.x = 0
		# moving a direction so use on ground speed value
		elif abs(direction.x) or curr_state.name == "DASH": 
			# add speed to velocity
			out = curr_state.calculate_velocity(direction, out)

			# set dashdance init. velocity
			if curr_state.get_name() == "DASH" and prev_state == "DASH_TURN": 
				out.x = facing * (DASH_SPEED - 0.5*SPEED)
				
		# else, use friction to slow down to stop 
		elif abs(out.x): 
			if abs(out.x) > FRICTION: 
				out.x -= FRICTION if out.x > 0 else -FRICTION
			else: 
				out.x = 0
				
	# else, in the air and not on the ground 
	else: 
		var abs_direction = abs(direction.x)
		# cap to max air speed, if not
		if abs(out.x) > MAX_AIR_SPEED: 
			out.x = sign(out.x) * MAX_AIR_SPEED
			
		# if arial drifting, use char air speed values - exclude deadzone values 
		if abs_direction > walk_thr: 
			# if less than threshold of 0.9, then use base accel * direction + addl. accel * abs_dir
			if abs_direction < smash_thr: 
				var temp_cap = MAX_AIR_SPEED * abs_direction
				
				# check for small difference setting
				if abs(temp_cap-abs(out.x)) < (BASE_AIR_ACCEL + (ADD_AIR_ACCEL*abs_direction)) and sign(out.x) == sign(direction.x): 
					out.x = sign(direction.x) * temp_cap
				elif abs(out.x) > temp_cap: 
					out.x -= sign(direction.x) * (BASE_AIR_ACCEL + (ADD_AIR_ACCEL*abs_direction))
				else:
					out.x += sign(direction.x) * (BASE_AIR_ACCEL + (ADD_AIR_ACCEL*abs_direction))
			
				
			# full send in one direction
			else: 
				out.x += sign(direction.x)*AIR_ACCEL
			
			if abs(out.x) > MAX_AIR_SPEED: 
				out.x = sign(out.x) * MAX_AIR_SPEED
				
		# else, no air drift input so use air traction 
		else: 
			if abs(out.x) > AIR_TRACTION: 
				out.x += -AIR_TRACTION * sign(out.x)
			else: 
				out.x = 0
				
	out.y += GRAVITY 
	
	# max fall speed
	if fastfalling: 
		out.y = FASTFALL_SPEED
	elif out.y > FALL_SPEED:
		out.y = FALL_SPEED
		
	return out


# Given the name of a new state, enter into that new state
func change_state(new_state):
	if new_state != null: 
		
		# DEBUG : dummy will hold shield in dummy_shield_mode
		if dummy_shield_mode:
			if is_on_floor() and curr_state.name == 'BLOCK':
				if new_state == 'HITFREEZE':  
					curr_state.exit()
					curr_state=states_map[new_state]
					curr_state.enter()
				return 
			else: 
				curr_state.exit()
				curr_state=states_map[new_state]
				if new_state == 'IDLE': 
					curr_state = states_map['BLOCK']
				curr_state.enter()
			return
			
		# make it so dummy can't attack or jump
#		if dummy_mode and (new_state == "AIR_ATTACK" or new_state == "GROUND_ATTACK" or new_state == "JUMP_SQUAT" or new_state=="BLOCK"): 
		if dummy_mode and curr_state.name in bad_dummy_states: 
			curr_state.exit()
			curr_state = states_map['IDLE']
			curr_state.enter()
			return
		elif dummy_mode and new_state in bad_dummy_states: 
			return

		prev_state = curr_state.name

		# store landing lag & add to new 
		var temp_landing_lag = 0
		if new_state == "LAND" and (prev_state == "AIR_ATTACK" or prev_state == "FREEFALL"): 
			temp_landing_lag = curr_state.landing_lag
			
		# add universal landing lag for wavedashing
		elif new_state == "LAND" and prev_state == 'AIRDODGE': 
			temp_landing_lag = 10
			
		curr_state.exit()
		curr_state = states_map[new_state]
		curr_state.enter()
		
		# if landing_lag exists, add to landing frames 
		if temp_landing_lag: 
			curr_state.landing_frames = temp_landing_lag
			

# checks the stick buffer if we've done a smash input
# window = 3 frames 
func check_smash_input(axis='x'): 
	# below : BUFFER OF 4 
	# if most recent input was a smash
	if axis=='x' and abs(stick_buffer.back().x) >= smash_thr: 
		# if the one before was also a smash input in the same direction, return false
#		if abs(stick_buffer[2].x) >= smash_thr and stick_buffer[2].x * stick_buffer.back().x > 0: 
#			return false; 

		# check that other 2 weren't in smash zone
		if abs(stick_buffer[0].x) < walk_thr or abs(stick_buffer[1].x) < walk_thr or abs(stick_buffer[2].x) < walk_thr: 
			return true
			
		# check if we snapped from a negative position: 
		elif stick_buffer[0].x*stick_buffer.back().x < 0 or stick_buffer[1].x*stick_buffer.back().x < 0 or stick_buffer[2].x*stick_buffer.back().x < 0: 
			return true
	
	# check in y direction
	elif axis=='y' and abs(stick_buffer.back().y) >= smash_thr: 
		# check that other 2 weren't in smash zone
		if abs(stick_buffer[0].y) < walk_thr or abs(stick_buffer[1].y) < walk_thr or abs(stick_buffer[2].y) < walk_thr: 
			return true
			
		# check if we snapped from a negative position: 
		elif stick_buffer[0].y*stick_buffer.back().y < 0 or stick_buffer[1].y*stick_buffer.back().y < 0 or stick_buffer[2].y*stick_buffer.back().y < 0: 
			return true

#	# this one: BUFFER OF 3 
#	if abs(stick_buffer.back().x) >= smash_thr: 
#		# if the one right before was also a smash in same dir, return false
#		if abs(stick_buffer[1].x) >= smash_thr and stick_buffer[1].x * stick_buffer.back().x > 0: 
#			return false
#		elif abs(stick_buffer[0].x) < walk_thr or abs(stick_buffer[1].x) < walk_thr: 
#			return true
#		elif stick_buffer[0].x*stick_buffer.back().x < 0 or stick_buffer[1].x*stick_buffer.back().x < 0: 
#			return true
	return false


# manage particle2D node 
# input: string style - can be one of "land", or "run" 
#	basically swtiches from horizontal-style particles and vertical particles
func set_particle_style(style): 
	# set facing direction, reset position (JIC)
	get_node("position/dust_particles").set_scale(Vector2(-facing, 1))
	get_node("position/dust_particles").process_material.set_color(Color(.7,.7,.7))
	get_node("position/dust_particles").process_material.initial_velocity = 800
	get_node("position/dust_particles").process_material.hue_variation = 0
	get_node("position/dust_particles").process_material.hue_variation_random = 0
	get_node("position/dust_particles").set_position(Vector2(0, 280))
	
	if style == "LAND": 
		get_node("position/dust_particles").process_material.set_direction(Vector3(0, -1, 0))
		get_node("position/dust_particles").process_material.set_spread(44)
		
	elif style == "RUN": 
		get_node("position/dust_particles").process_material.set_direction(Vector3(1, -0.3, 0))
		get_node("position/dust_particles").process_material.set_spread(25)
	
	elif style == "BLAST": 
		get_node("position/dust_particles").process_material.set_direction(Vector3(1, 0, 0))
		get_node("position/dust_particles").process_material.set_spread(180)
		get_node("position/dust_particles").process_material.initial_velocity = 1500
		get_node("position/dust_particles").process_material.set_color(Color(1,0.55,0.1))
		get_node("position/dust_particles").process_material.set_gravity(Vector3(0,0,0))
		get_node("position/dust_particles").process_material.hue_variation = 0.15
		get_node("position/dust_particles").process_material.hue_variation_random = 0.5

# sets the properties of the shader
func set_shader(color, width = -1): 
	pass

# turns on the current shader
func activate_shader(): 
	pass

# turns off the shader
func deactivate_shader(): 
	pass

# handle flipping Sprite and ECB
# input : DIR - either +/- 1, the direction the sprite should be facing 
func flip_direction(dir): 
	if facing != dir: 
		facing = dir
		$position/body.set_scale(Vector2(facing,1))
		$ECB.set_scale(Vector2(facing,1))
		
		# jank flip for air_ecb
		$AIR_ECB.set_position(Vector2(facing*16,1))
#		$AIR_ECB.set_scale(Vector2(facing,1))


# handles the state, animation, and physics change for getting hit 
# INPUT: hitbox - an instance of the hitbox node, located in 'hboxes/hitbox.tscn'
func _get_hit(hitbox) -> void: 
	var KB_COEFFICIENT = 5
	var X_AXIS_COEFF = 0.75
	
	# activate hitsparks
	$position/body/hitspark_generator.activate()
	
	# add to has_hit list of person who put out the hitbox
	
	# flip playermodel to be facing attacker
	if position.x > get_parent().owner.PLAYERS[hitbox.PLAYER_ID].CHARACTER_INSTANCE.position.x: 
		flip_direction(-1)
	else: 
		flip_direction(1)
	
	# knockback calculation
	var kb = 1.4 * (((hitbox.damage+2)*(hitbox.damage+floor(PERCENT)))/20)
	kb *= (2.0 - ((2*WEIGHT/100.0)/(1+WEIGHT/100.0)))
	kb += 18
	kb *= hitbox.kb_growth/100.0
	kb += hitbox.base_knockback
	
	# DEBUG: % printing
#	print(ID,"( %",PERCENT," )", " : got hit by ", hitbox.PLAYER_ID, " - ", hitbox.attack_name, " (kb value of : ", kb, ").")
	
	# Apply damage and go to hitfreeze
	PERCENT += hitbox.damage
	change_state("HITFREEZE")
	curr_state.kb_val = kb
	curr_state.HITSTUN_FRAMES = max(floor(kb*0.4), hitbox.base_hitstun)
	curr_state.HITFREEZE_FRAMES = (floor(hitbox.damage/3) + 3)
	
	# check for reverse hits
	var tang = hitbox.kb_angle
	
	# check for spike into ground sending upwards
	if kb > 80 and hitbox.kb_angle < 0:
		if is_on_floor(): 
			tang *= -1
		
	if position.x < get_parent().owner.PLAYERS[hitbox.PLAYER_ID].CHARACTER_INSTANCE.position.x: 
		tang = 180 - tang
	
#			print("Launch angle: ", tang)

		# TODO: calculate DI here, as in how hit player's directional input affects launch angle? 
		
	tang = deg2rad(tang)
	
	# constant term that translates calculated KB to velocity
	#	hard to tell what will be... good
	curr_state.exit_velocity = Vector2(cos(tang), -sin(tang)) * kb * KB_COEFFICIENT
	# scale x-axis knockback to make the game not so shitty feeling to combo? 
	curr_state.exit_velocity.x *= X_AXIS_COEFF
	
	# apply hitlag to attacker, if non projectile
	if !hitbox.IS_PROJECTILE: 
		# add to attacker's has_hit index: 
		hitbox.get_parent().owner.has_hit[ID] = hitbox.priority
		
		hitbox.get_parent().owner.get_node("AnimationPlayer").stop(false)
		if hitbox.get_parent().owner.curr_state.name == "GROUND_ATTACK" or hitbox.get_parent().owner.curr_state.name == "AIR_ATTACK":
			# set hitlag properties on the owner of the hitbox 
			hitbox.get_parent().owner.HITLAG_VELOCITY = hitbox.get_parent().owner.velocity
			hitbox.get_parent().owner.HITLAG_FRAMES = curr_state.HITFREEZE_FRAMES

	# if is a projectile, then projectile should dissappear / destroy itself
	else: 
		hitbox.destroy()
			
	# clear deferred hitbox
	DEFERRED_HITBOX = null


func _get_grabbed(hitbox) -> void: 	
	change_state("GRABBED_STATE")
	hitbox.get_parent().owner.has_hit[ID] = hitbox.priority
	
	# trigger the grab 
	hitbox.get_parent().owner.curr_state.trigger_grab(self)
	
	# set GRABBED_STATE to point to the grabber 
	curr_state.set_grabber(hitbox.get_parent().owner)
	curr_state.turn_and_snap()
	return 


# handle getting hit / having something interact with char's hurtbox
func _on_hurtboxes_area_entered(area: Area2D) -> void:
	var hitbox = area.owner
	
	# hit the blastzone, dead - handled by the game logic
	if hitbox.name == "Stage": 
		return
	
	# player cannot be hit by their own hitbox
	elif hitbox.PLAYER_ID != ID: 
		# check for grab
		if hitbox.IS_GRAB: 
			DEFERRED_HITBOX = hitbox
			DEFERRED_PRIORITY = hitbox.priority
			
		# check for projectile
		elif hitbox.IS_PROJECTILE: 
			if not DEFERRED_HITBOX or hitbox.priority > DEFERRED_PRIORITY: 
				DEFERRED_HITBOX = hitbox
				DEFERRED_PRIORITY = hitbox.priority
			
		# else, got hit by a hitbox
		# check to see that we're not hitting ourselves / same hitbox isn't hitting multiple times 
		elif !hitbox.get_parent().owner.has_hit.has(ID):
	#		if curr_state.name == 'BLOCK': 
			# defer the hitbox anyway
	#		if not DEFERRED_HITBOX: 
	#			DEFERRED_HITBOX = hitbox
	#			DEFERRED_PRIORITY = hitbox.priority
			if not DEFERRED_HITBOX or hitbox.priority > DEFERRED_PRIORITY: 
				DEFERRED_HITBOX = hitbox
				DEFERRED_PRIORITY = hitbox.priority
			
		# old way 
#		if !hitbox.get_parent().owner.has_hit.has(ID) or hitbox.get_parent().owner.has_hit[ID] < hitbox.priority:
#			_get_hit(hitbox)


func _on_shield_area_entered(area: Area2D) -> void:
	var hitbox = area.owner
	if hitbox.PLAYER_ID != ID: 
		# if ID not in player's has_hit dict, then shield takes the hit 
		if not hitbox.get_parent().owner.has_hit.has(ID):
			hitbox.get_parent().owner.has_hit[ID] = hitbox.priority
			# shield takes damage
			# TODO: find appropriate scaling for shield hp
			SHIELD_HP -= hitbox.damage * 0.9
			
			# TODO:  call shieldstun fcn			
			if hitbox.get_parent().owner.position.x > position.x: 
				curr_state._shield_stun(hitbox.damage, 1)
			else: 
				curr_state._shield_stun(hitbox.damage, -1)


# handle ledgegrabbing when ledge enters ledgegrab_box
func _on_ledgegrab_box_area_entered(area: Area2D) -> void:
	# non ledge-grabbable states
	if curr_state.name != 'LEDGE_HANG' and curr_state.name != 'AIR_ATTACK' and not is_on_floor(): 
		# flip to face the correct way
		if area.DIRECTION * facing != -1 : 
			flip_direction(-area.DIRECTION)
			
		# set position to ledge position
		position = area.LEDGE_GRAB_POSITION
		
		change_state('LEDGE_HANG')

# makes the character invincible for x amount of frames
func _make_invincible(frames: int): 
	for hurtbox in get_node("position/body/hurtboxes").get_children(): 
		hurtbox.disabled = true
		INV_FLAG = frames
		

func _enable_hurtboxes(): 
	for hurtbox in get_node("position/body/hurtboxes").get_children(): 
		hurtbox.disabled = false
