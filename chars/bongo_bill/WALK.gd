extends "../state_template.gd"
var max_speed = 100
	
func enter():
	owner.get_node("AnimationPlayer").play("WALK")
	max_speed = owner.WALK_SPEED
	
	# flip to face the correct way 
	if sign(owner.stick_buffer.back().x) != owner.facing: 
		owner.flip_direction(sign(owner.stick_buffer.back().x))
		
		
func process_input(dir): 
	return dir
	
# caps max walk speed based on strength of the input
func calculate_velocity(dir, curr_vel):
	# should make this 
	var out = curr_vel
	var speed_cap = owner.WALK_SPEED
	# max walk speed
	if abs(dir.x) > 0.9: 
		out.x += sign(dir.x) * (owner.BASE_WALK_ACCEL + owner.ADD_WALK_ACCEL)
	# medium walk speed 
	elif abs(dir.x) > 0.5 and abs(dir.x) < 0.9: 
		out.x += sign(dir.x) * (owner.BASE_WALK_ACCEL+((abs(dir.x)+0.1)*owner.ADD_RUN_ACCEL))
		speed_cap *= 0.7
	# slow walk speed 
	else: 
		out.x += sign(dir.x) * owner.BASE_WALK_ACCEL 
		speed_cap *= 0.5
	# cap speed
	if abs(out.x) > speed_cap: 
		out.x = sign(out.x) * speed_cap
	# check for flip
	if sign(out.x) != owner.facing: 
		owner.flip_direction(sign(out.x))
	return out

func check_state(): 
	if abs(owner.stick_buffer.back().x) < owner.walk_thr: 
		return "IDLE"
	# check for smash input, incase of dash
	elif owner.check_smash_input(): 
		return "DASH"
	elif owner.stick_buffer.back().y > 0.5 and owner.stick_buffer.back().y > owner.stick_buffer.back().x:
		return "CROUCH_SQUAT"
	elif !owner.is_on_floor(): 
		return "FALL"
	elif Input.is_action_pressed("jump"):
		return "JUMP_SQUAT"
	elif Input.is_action_just_pressed("attack"):
		return "GROUND_ATTACK"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
	elif Input.is_action_just_pressed("grab"): 
		return "GRAB"
