extends KinematicBody2D
const FLOOR_NORMAL: = Vector2.UP

# characters ground movement properties 
var SPEED = 25
var BASE_RUN_ACCEL = 10
var ADD_RUN_ACCEL = 15 # add'l run accel. depending on how hard you're pressing forward
var JUMP_FORCE = 310
var friction = 8
var RUN_SPEED = 230.0
var WALK_SPEED = 85
var DASH_SPEED = 200

# Characters air movement properties
var AIR_ACCEL = 6
var BASE_AIR_ACCEL = 2
var ADD_AIR_ACCEL = 4
var MAX_AIR_SPEED = 112.0
var AIR_TRACTION = 1
var FALL_SPEED = 290
var FASTFALL_SPEED = 350
var GRAVITY = 13

# NOTE : using 0.65 as the dash thresh
# so zones look like this: 
# 0.00 - 0.10 : deadzone
# 0.10 - 0.60 : walk
# 0.60 - 0.8 : slow run / non-smash
# 0.80 - 1.0 : fast run / smash input
var dash_thr = 0.6
var walk_thr = 0.1
var smash_thr = 0.8
var stick_buffer = [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO, Vector2.ZERO]

# all ID's of players hit from the last attack
# cleared on exiting ground/air attack state, or hitstun state
var has_hit = {}

# set ID in the metagame, somehow..? 
export(int) var ID
var WEIGHT = 300

# character's current velocity
var velocity: = Vector2.ZERO
# track the number of jumps char has avaliable + if they're currently fastfalling
var MAX_JUMPS = 2
var jumps = 2
var fastfalling = false
var tumbling = false

# character's current HP and shield HP
var percent = 0.0
var shield_hp = 0

# keep track of the current and just prior state 
# note: curr_state = actual node in state machine
# 		prev_state = (string) name of the state
var curr_state = null
var prev_state = null
# dict to store state names : node references
var states_map = null

# keep track of direction sprite is facing: 1 == facing right, -1 == facing left
export var facing = -1

# TESTING VARS 
var curr_anim = null
var last_input = Vector2.ZERO

# if true, then remove all input for character (so it just stands still)
var dummy_mode = false

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
		"HIT_FREEZE": $States/HIT_FREEZE, 
		"HITSTUN": $States/HITSTUN
	}
	curr_state = get_node("States/IDLE")
	curr_state.enter()
	$position/body.set_scale(Vector2(facing, 1))


func _physics_process(delta: float) -> void:
	# let states do their per/frame thing 
	curr_state.state_logic(delta)
	
	var dir = read_input()
	
	if dir != last_input: 
		last_input = dir
	
	velocity = calculate_move_velocity(velocity, dir, curr_state)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)
	
	# check for state change 
	change_state(curr_state.check_state())
	
	#TESTING: print current animation 
#	if $AnimationPlayer.get_current_animation() != curr_anim: 
#		print("current animation: ", $AnimationPlayer.get_current_animation())
#	curr_anim = $AnimationPlayer.get_current_animation()
	
# read the input, returns the unit vector of the direction held on left stick
func read_input(): 
	var out = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-Input.get_action_strength("stick_up") + Input.get_action_strength("crouch")
	)
	if dummy_mode: 
		out = Vector2.ZERO
	
	# normalize according to stick calibration... 
	# FOR SWITCH: divide by 0.75
	if Input.get_joy_name(0) != "":
		out.x /= 0.75
		out.y /= 0.75

	if Input.is_action_pressed("walk_key"): 
		out.x *= 0.5
	
	# handle the input
	# add input to input buffer
	out = curr_state.process_input(out)
	stick_buffer.pop_front()
	stick_buffer.push_back(out)
	
	return out
	
	
	
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
	if curr_state.name == "RUN_STOP": 
		direction.x = 0
	elif curr_state.name == "HIT_FREEZE" or (curr_state.name == "AIR_ATTACK" and curr_state.hitlag_frames > 0): 
		return Vector2.ZERO
	
	if is_on_floor(): 
		# mid dash dance, set velocity to 0
		if curr_state.name == "DASH_TURN": 
			out.x = 0
		# moving a direction so use on ground speed value
		elif abs(direction.x) or curr_state.name == "DASH": 
			# add speed to velocity
			
			out = curr_state.calculate_velocity(direction, out)
			
#			# speed varies based on strength of stick input
#			if curr_state.name == "DASH" or curr_state.name == "RUN": 
#				# base run
#				if abs(direction.x) <= 0.6: 
#					out.x += BASE_RUN_ACCEL * sign(direction.x)
#				# base run + amount based on input
#				elif abs(direction.x) > 0.6 and abs(direction.x) < 0.9: 
#					out.x += sign(direction.x)*(BASE_RUN_ACCEL + ((abs(direction.x) - 0.6)/0.3)*ADD_RUN_ACCEL)
#				# max run, or base run + full add_run
#				else: 
#					out.x += sign(direction.x) * (BASE_RUN_ACCEL + ADD_RUN_ACCEL)
#
#			else: 	
#				out.x += direction.x * SPEED	
#
#			# set our current topspeed based on our state
#			var topspeed = 230
#			match curr_state.name: 
#				"WALK":
#					topspeed = WALK_SPEED
#				"DASH":
#					topspeed = DASH_SPEED
#				"RUN":
#					topspeed = RUN_SPEED
#
#			# fix to topspeed
#			if abs(out.x) > topspeed:
#				out.x = sign(out.x) * topspeed

			# set dashdance init. velocity
			if curr_state.get_name() == "DASH" and prev_state == "DASH_TURN": 
				out.x = facing * (DASH_SPEED - 0.5*SPEED)
				
		# else, use friction to slow down to stop 
		elif abs(out.x): 
			if abs(out.x) > friction: 
				out.x -= friction if out.x > 0 else -friction
			else: 
				out.x = 0
				
	# else, in the air and not on the ground 
	else: 
		var abs_direction = abs(direction.x)
		# cap to max air speed, if not
		if abs(out.x) > MAX_AIR_SPEED: 
			out.x = sign(out.x) * MAX_AIR_SPEED
			
		# if arial drifting, use char air speed values 
		if abs_direction: 
			# if less than threshold of 0.9, then use base accel + direction * addl. accel 
			if abs_direction < 0.9: 
				out.x += sign(direction.x) * (BASE_AIR_ACCEL + (ADD_AIR_ACCEL*abs_direction))
			else: 
				out.x += sign(direction.x) * (AIR_ACCEL)
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
	

# enter into new state
func change_state(new_state):
	if new_state != null: 
		# make it so dummy can't attack or jump
		if dummy_mode and (new_state == "AIR_ATTACK" or new_state == "GROUND_ATTACK" or new_state == "JUMP_SQUAT" or new_state == "DOUBLE_JUMP"): 
			return
		prev_state = curr_state.name
		# store landing lag & add to new 
		var llag = 0
		if new_state == "LAND" and prev_state == "AIR_ATTACK": 
			llag = curr_state.landing_lag
			
		curr_state.exit()
		curr_state = states_map[new_state]
		curr_state.enter()
		
		# if llag exists, add to landing frames 
		if llag: 
			curr_state.landing_frames = llag


# checks the stick buffer if we've done a smash input
# window = 3 frames 
func check_smash_input(): 
	# below : BUFFER OF 4 
	# if most recent input was a smash
	if abs(stick_buffer.back().x) >= smash_thr: 
		# if the one before was also a smash input in the same direction, return false
		if abs(stick_buffer[2].x) >= smash_thr and stick_buffer[2].x * stick_buffer.back().x > 0: 
			return false; 
		# check that other 2 weren't in smash zone
		elif abs(stick_buffer[0].x) < walk_thr or abs(stick_buffer[1].x) < walk_thr or abs(stick_buffer[2].x) < walk_thr: 
			return true
		# check if we snapped from a negative position: 
		elif stick_buffer[0].x*stick_buffer.back().x < 0 or stick_buffer[1].x*stick_buffer.back().x < 0 or stick_buffer[2].x*stick_buffer.back().x < 0: 
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
		

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var hitbox = area.owner
	# hit the blastzone, dead - handled by the game logic
	if hitbox.name == "Stage": 
		return
		
	# else, got hit by a hitbox
	# check to see that we're not hitting ourselves / same hitbox isn't hitting multiple times 
#	elif hitbox.player_id != ID and !hitbox.get_parent().owner.has_hit.has(ID): 
	elif hitbox.player_id != ID: 
		if !hitbox.get_parent().owner.has_hit.has(ID) or hitbox.get_parent().owner.has_hit[ID] < hitbox.priority:
			# add to has_hit list of person who put out the hitbox
	#		hitbox.get_parent().owner.has_hit.append(ID)
			hitbox.get_parent().owner.has_hit[ID] = hitbox.priority
			
			# flip playermodel to be facing attacker
			$position/body.set_scale(Vector2(-hitbox.get_parent().owner.facing, 1))
			
			# knockback calculation
			var kb = 1.4 * (((hitbox.damage+2)*(hitbox.damage+floor(percent)))/20)
			kb *= (2.0 - ((2*WEIGHT/100)/(1+WEIGHT/100)))
			kb += 18
			kb *= hitbox.kb_growth/100.0
			kb += hitbox.base_knockback
			
			print(ID,"(",percent,")", " : got hit by ", hitbox.player_id, " - ", hitbox.attack_name, " (kb value of : ", kb, ").")
			
			percent += hitbox.damage
			change_state("HIT_FREEZE")
			curr_state.kb_val = kb
			curr_state.hs_frames = floor(kb*0.4)
			curr_state.hlag_frames = (hitbox.damage/3 + 3)
			print("hs frames -- ", curr_state.hs_frames)
			
			var tang = hitbox.kb_angle
			if position.x < get_parent().owner.PLAYER_IDS[hitbox.player_id].position.x: 
				tang = 180 - tang
			
			print("Launch angle: ", tang)
				
			tang = deg2rad(tang)
			curr_state.exit_velocity = Vector2(cos(tang), -sin(tang)) * kb * 5
			
			# apply hitlag to attacker
			hitbox.get_parent().owner.get_node("AnimationPlayer").stop(false)
			if hitbox.get_parent().owner.curr_state.name == "GROUND_ATTACK" or hitbox.get_parent().owner.curr_state.name == "AIR_ATTACK":
#				hitbox.get_parent().owner.curr_state.CURRENT_ATTACK.HITLAG_VEL = hitbox.get_parent().owner.velocity
#				hitbox.get_parent().owner.curr_state.CURRENT_ATTACK.HITLAG_FRAMES = (hitbox.damage/3 + 3)

				hitbox.get_parent().owner.HITLAG_VELOCITY = hitbox.get_parent().owner.velocity
				hitbox.get_parent().owner.HITLAG_FRAMES = (hitbox.damage/3) + 3



