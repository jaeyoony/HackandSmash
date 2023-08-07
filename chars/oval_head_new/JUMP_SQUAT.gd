extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return "JUMP_SQUAT"
	
func enter(): 
	owner.get_node("AnimationPlayer").play("JUMP_SQUAT")
	# check if we're facing the right way
	return
	
func state_logic(delta): 
	ticker += 1
	return

func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	if abs(curr_velocity.x) > owner.friction: 
		out.x = curr_velocity.x - sign(owner.friction)
	else: 
		out.x = 0
	return out

func process_input(dir):
	if ticker == 5:
		# check for fullhop vs shorthop
		# note: adding an extra GRAVITY value to jump force b/c gravity will be calculated before 
		# 		move and slide, so adding it here will make sure upwards vel. is the full value 
		if Input.is_action_pressed("jump"):
			owner.velocity.y = -(owner.JUMP_FORCE + owner.GRAVITY)
		else:
			owner.velocity.y = -(owner.JUMP_FORCE * 0.6 + owner.GRAVITY)
	return dir
	
func exit(): 
	owner.jumps -= 1 
	ticker = 0

func check_state(): 
	if ticker == 5: 
		return "JUMP"
