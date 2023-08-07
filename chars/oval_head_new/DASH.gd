extends "../state_template.gd"

var ticker = 0

func get_name(): 
	return("DASH")

func enter():
	owner.get_node("AnimationPlayer").play("DASH")
	# fix facing 
	if owner.stick_buffer.back().x * owner.facing < 0: 
		owner.get_node("position/body").set_scale(Vector2(sign(owner.stick_buffer.back().x),1))
		owner.facing = sign(owner.stick_buffer.back().x)
	# set speed values
	
#func process_input(dir): 
#	# if we're in initial dash, keep moving
#	if(ticker < 14) and owner.is_on_floor(): 
#		if not abs(dir.x): 
#			dir.x = owner.facing * owner.dash_thr
#	return dir
#
func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	var dash_cap = owner.DASH_SPEED
	# slow run 
	if abs(dir.x) <= 0.5: 
		out.x += owner.BASE_RUN_ACCEL* sign(dir.x)
	# mid speed run 
	elif abs(dir.x) > 0.5 and abs(out.x) < 0.9: 
		out.x += sign(dir.x) * (owner.BASE_RUN_ACCEL+((abs(dir.x)+0.1)*owner.ADD_RUN_ACCEL))
	# full speed run 
	else: 
		out.x += sign(dir.x) * (owner.BASE_RUN_ACCEL + owner.ADD_RUN_ACCEL)
	# cap speed if higher
	if abs(out.x) >= dash_cap:
		out.x = sign(out.x) * dash_cap
	return out

func state_logic(delta): 
	ticker += 1

func exit(): 
	ticker = 0

func check_state(): 
	var x_in = owner.stick_buffer.back().x
	
	if !owner.is_on_floor(): 
		owner.jumps -= 1
		return "FALL"
		
	elif Input.is_action_just_pressed("jump"):
		return "JUMP_SQUAT"
	# dashdance -> go into dash turn
	elif owner.facing * x_in < 0 and owner.check_smash_input(): 
		return "DASH_TURN"
	elif Input.is_action_just_pressed("attack"): 
		return "GROUND_ATTACK"
		
	elif ticker > 15: 
		if owner.facing == 1 and  Input.get_action_strength("move_right") < 0.5: 
			return "IDLE"
		elif owner.facing == -1 and Input.get_action_strength("move_left") < 0.5: 
			return "IDLE"
		else: 
			return "RUN"
	
	return


