extends "../state_template.gd"

var ticker = 0

func get_name(): 
	return("IDLE")

func enter():
	owner.get_node("AnimationPlayer").play("IDLE")

func calculate_velocity(dir, curr_vel):
	var out = curr_vel
	if abs(out.x) > owner.FRICTION: 
		out.x -= owner.FRICTION if out.x > 0 else -owner.FRICTION
	else: 
		out.x = 0
		
	return out


func check_state(): 
#	var x_in = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	var x_in = owner.stick_buffer.back().x
	# check for walk
	if !owner.is_on_floor(): 
		owner.jumps -= 1
		return "FALL"
#	elif Input.get_action_strength("crouch") > 0.6:
	elif owner.stick_buffer.back().y > abs(owner.stick_buffer.back().x) and owner.stick_buffer.back().y > 0.5:
		return "CROUCH_SQUAT"
	elif Input.is_action_just_pressed("jump"):
		return "JUMP_SQUAT"
	elif Input.is_action_pressed("shield"): 
		return "BLOCK"
	elif Input.is_action_just_pressed("attack"):
		return "GROUND_ATTACK"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
	elif Input.is_action_just_pressed("grab"): 
		return "GRAB"
		
#	elif (Input.is_action_pressed("walk_key") or abs(x_in) < owner.dash_thr) and abs(x_in) > 0: 
#		# check for just walk key being held
#		return "WALK"
		
	elif owner.check_smash_input(): 
		return "DASH"
	elif abs(x_in) > owner.walk_thr: 
		return "WALK"
	return


