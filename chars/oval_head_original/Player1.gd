extends Actor


var animation_state_machine
var curr_state = null
var last_state = null

# length of jumpsquat, in frames 
var JS_LEN = 5
var IDASH_LEN = 16
var DB_LEN = 30
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_state_machine = $AnimationTree.get('parameters/playback')
	# set specific char traits like jumps, speed, air drift, etc. 
	set_state(states.IDLE)
	jumps = MAX_JUMPS

func _physics_process(delta: float) -> void:
	# update action buffer first
	if ACTION_TIMER: ACTION_TIMER -= 1
#	var is_jump_interrupted: = Input.is_action_just_released("jump") and velocity.y < 0.0
	var direction: = read_input()
		
	velocity = calculate_move_velocity(velocity, speed, direction, curr_state)
	velocity = move_and_slide(velocity, FLOOR_NORMAL)

# sets the state of the animation tree
func set_state(next_state) -> void: 
	last_state = curr_state
	animation_state_machine.travel(state_strs[next_state])
#	if(curr_state and last_state):
#		print(state_strs[last_state], " : ", state_strs[next_state])


# gets the direction of travel based on player's inputs 
func read_input() -> Vector2: 
	var out = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		1.0
	)
	# check for state change, default it to the same as rn
#	print(animation_state_machine.get_current_node())	
#	curr_state = state_enums[animation_state_machine.get_current_node()]
	var temp = animation_state_machine.get_current_node()
	if temp: 
		curr_state = states[temp]
	var next_state = curr_state
	
	# check for walk key
	if Input.is_action_pressed("walk_key") and (curr_state != states.DASH_START and curr_state != states.DASH_IDLE):
		out.x *= 0.6
		
	
	# check for specific actions out of specific statesv
	match curr_state: 
		states.IDLE, states.WALK:
			# check for jump input, takes priority 
			if !is_on_floor(): 
				next_state = states.JUMP_IDLE
			elif Input.is_action_just_pressed("jump") and is_on_floor():
				ACTION_BUFFER = states.JUMP_IDLE
				ACTION_TIMER = JS_LEN
				next_state = states.JUMP_SQUAT
			elif is_on_floor() and Input.is_action_pressed("crouch"):
				out.x = 0
				next_state = states.CROUCH_IDLE
			# if fast enough, initiate dash
			elif abs(out.x) > 0.7:
				# flip to direction of dash input
				$body.set_scale(Vector2(out.x/abs(out.x), 1))
				ACTION_BUFFER = states.DASH_IDLE
				ACTION_TIMER = IDASH_LEN
				next_state = states.DASH_START
			elif out.x != 0:
				next_state = states.WALK
			else: 
				next_state = states.IDLE
			
		states.DASH_START: 
			if !is_on_floor(): 
				next_state = states.JUMP_IDLE
			# check for dash dance
			elif velocity.x * out.x < 0: 
				next_state = states.DASH_DANCE_TURNAROUND
			elif Input.is_action_just_pressed("jump") and is_on_floor(): 
				ACTION_BUFFER = states.JUMP_IDLE
				ACTION_TIMER = JS_LEN
				next_state = states.JUMP_SQUAT
			elif ACTION_TIMER == 0:
				if(out.x == 0): 
					next_state = states.DASH_STOP
				else:
					next_state = states.DASH_IDLE
				ACTION_BUFFER = null
				ACTION_TIMER = null
			# initial dash should always be moving
			else: 
				out.x = $body.get_scale().x
			
		states.DASH_DANCE_TURNAROUND: 
			# flip & reset action timer for new init.dash
			$body.set_scale(Vector2(-1*$body.get_scale().x,1))
			ACTION_TIMER = IDASH_LEN
		
		states.DASH_IDLE: 
			if !is_on_floor(): 
				next_state = states.JUMP_IDLE
			# user input long dashback, outside of initial dash window.
			elif abs(out.x) > 0.7 and out.x * velocity.x < 0:
				next_state = states.DASH_BACK
				ACTION_BUFFER = states.DASH_IDLE
				ACTION_TIMER = DB_LEN
			elif Input.is_action_just_pressed("jump") and is_on_floor(): 
				ACTION_BUFFER = states.JUMP_IDLE
				ACTION_TIMER = JS_LEN
				next_state = states.JUMP_SQUAT
			elif is_on_floor() and Input.is_action_pressed("crouch"): 
				out.x = 0
				next_state = states.CROUCH_IDLE
			elif out.x == 0: 
				next_state = states.DASH_STOP
			
		states.DASH_BACK: 
			# at the last frame, turnaround
			if ACTION_TIMER == 0: 
				# check if opp. direction is still being held. if it isn't, just turnaround & stand still
				if out.x == 0: 
					$body.set_scale(Vector2(-1*$body.get_scale().x, 1))
					next_state = states.IDLE
					out.x = 0
				# else, turn
				else: 
					$body.set_scale(Vector2(-1*$body.get_scale().x, 1))
					next_state = states.DASH_IDLE
					ACTION_TIMER = null
					ACTION_BUFFER = null
			else: 
#				print("dashing back, no turn... facing: ", $body.get_scale().x)
#				print("ACTION_TIMER:", ACTION_TIMER)
				out.x = 0.25 * $body.get_scale().x
			
		states.DASH_STOP:
			# check for dashback
			if $body.get_scale().x == 1 and out.x < -0.7: 
				next_state = states.DASH_BACK
				ACTION_TIMER = DB_LEN
			elif $body.get_scale().x == -1 and out.x > 0.7: 
				next_state = states.DASH_BACK
				ACTION_TIMER = DB_LEN
			out.x = 0.25* $body.get_scale().x
			
		states.CROUCH_IDLE:
			if is_on_floor() and !Input.is_action_pressed("crouch"):
				if abs(out.x) > 0.7: 
					next_state = states.WALK 
				else: 
					next_state = states.IDLE
			else: 
				out.x = 0
				
		states.JUMP_SQUAT:
			# time to jump?
			if ACTION_TIMER == 0:
				# if jump pressed, then fullhop. Else, shorthop
				if Input.is_action_pressed("jump"):
					out.y = -1.0
				else: 
					out.y = -0.7
				next_state = states.JUMP_IDLE
				# reset buffer, decr. jump counter
				ACTION_BUFFER = null
				ACTION_TIMER = null
				jumps -= 1
					
		states.JUMP_ASCEND, states.JUMP_IDLE:
			if jumps == MAX_JUMPS: 
				jumps -= 1
			if is_on_floor(): 
				next_state = states.LAND
			# double jump
			elif Input.is_action_just_pressed("jump") and jumps > 0:
				out.y = -1
				if out.x < 0: 
					$body.set_scale(Vector2(-1,1))	
				elif out.x > 0: 
					$body.set_scale(Vector2(1,1))
				next_state = states.DOUBLE_JUMP
				jumps -= 1
				
		states.DOUBLE_JUMP: 
			if Input.is_action_just_pressed("jump") and jumps > 0: 
				jumps -= 1 
				out.y = -1
				if out.x < 0: 
					$body.set_scale(Vector2(-1,1))
				elif out.x > 0: 
					$body.set_scale(Vector2(1,1))
				next_state = states.DOUBLE_JUMP
				# change curr_state so animation replays
				curr_state = null
				
			elif is_on_floor():
				next_state= states.LAND
				
		states.LAND: 
			jumps = MAX_JUMPS
			if Input.is_action_pressed("crouch"): 
				next_state = states.CROUCH_IDLE
			elif Input.is_action_pressed("jump"): 
				ACTION_BUFFER = states.JUMP_IDLE
				ACTION_TIMER = JS_LEN
				next_state = states.JUMP_SQUAT
			else:
				out.x *= 0.1
				next_state = states.IDLE
			
				
	# change states, if we need to
	if next_state != curr_state: 
		set_state(next_state)

	# return the direction
	return out

	
# calculates the new velocity of the character on next frame, using
#	character's current vel, their speed, and the most recent inputs (direction)
func calculate_move_velocity(
		linear_velocity:Vector2, 
		speed: Vector2, 
		direction: Vector2, 
		curr_state
	) -> Vector2: 
	# the current velocity of character 
	var out: = linear_velocity
	
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	
	if curr_state == states.DASH_START:
		out.x *= 1.5
	# if the player input a jump
	if direction.y < 0.0: 
		out.y = speed.y * direction.y
	# max fall speed
	if out.y > air_speed.y:
		out.y = air_speed.y
	# set direction 
	return out
	
	
	
