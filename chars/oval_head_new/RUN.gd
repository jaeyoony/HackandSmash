extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return("RUN")

func enter():
	owner.get_node("AnimationPlayer").play("RUN")
	

func state_logic(delta): 
	ticker += 1

func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	var speed_cap = owner.RUN_SPEED
	
	if abs(dir.x) <= 0.5: 
		out.x += owner.BASE_RUN_ACCEL* sign(dir.x)
		speed_cap = 0.7 * speed_cap
		
	elif abs(dir.x) > 0.5 and abs(dir.x) < 0.9: 
		out.x += sign(dir.x) * (owner.BASE_RUN_ACCEL+((abs(dir.x)-0.5/0.4)*owner.ADD_RUN_ACCEL))
		speed_cap = min(1, (abs(dir.x) + 0.2)) * speed_cap
		
	else: 
		out.x += sign(dir.x) * (owner.BASE_RUN_ACCEL + owner.ADD_RUN_ACCEL)
	# cap speed if higher
	if abs(out.x) >= speed_cap: 
		out.x = sign(out.x) * speed_cap
	return out

func exit(): 
	ticker = 0

func check_state(): 
	if !owner.is_on_floor(): 
		owner.jumps -= 1
		return "FALL"
	elif Input.is_action_just_pressed("jump"):
		return "JUMP_SQUAT"
#	if owner.facing == 1 and  Input.get_action_strength("move_right") < 0.5: 
#		return "RUN_STOP"
#	elif owner.facing == -1 and Input.get_action_strength("move_left") < 0.5: 
#		return "RUN_STOP"
	elif Input.is_action_just_pressed("attack"): 
		return "GROUND_ATTACK"
	elif owner.facing * owner.stick_buffer.back().x < 0:
		return "RUN_STOP"
	elif owner.stick_buffer.back().x == 0: 
		return "RUN_STOP"
	
	return


