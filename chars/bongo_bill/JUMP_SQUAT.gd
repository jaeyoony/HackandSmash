extends "../state_template.gd"
var ticker = 0
var BUFFERED_AIRDODGE = false

func get_name(): 
	return "JUMP_SQUAT"
	
func enter(): 
	owner.get_node("AnimationPlayer").play("JUMP_SQUAT")
	# check for buffered airdodge press
	if Input.is_action_just_pressed("shield"): 
		BUFFERED_AIRDODGE=true
	return
	
func state_logic(delta): 
	ticker += 1
	return

func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	if abs(curr_velocity.x) > owner.FRICTION: 
		out.x = curr_velocity.x - sign(curr_velocity.x)*owner.FRICTION
	else: 
		out.x = 0
	return out

func process_input(dir):
	# MOVED TO JUMP 
#	if ticker == 20:
		# check for fullhop vs shorthop
		# note: adding an extra GRAVITY value to jump force b/c gravity will be calculated before 
		# 		move and slide, so adding it here will make sure upwards vel. is the full value 
#		if Input.is_action_pressed("jump"):
#			owner.velocity.y = -(owner.JUMP_FORCE + owner.GRAVITY)
#		else:
#			owner.velocity.y = -(owner.JUMP_FORCE * 0.6 + owner.GRAVITY)
	# check for buffered wavedash 
	if Input.is_action_just_pressed("shield"): 
		BUFFERED_AIRDODGE=true
	return dir
	
func exit(): 
	owner.jumps -= 1 
	BUFFERED_AIRDODGE=false
	ticker = 0

func check_state(): 
	if ticker == 4: 
		if BUFFERED_AIRDODGE and owner.AIRDODGE_AVAILABLE: 
			return "AIRDODGE"
		return "JUMP"
