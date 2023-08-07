extends "../state_template.gd"
var ticker = 0
var landing_frames = 4

func get_name(): 
	return "LAND"
	
func enter(): 
	owner.jumps = owner.MAX_JUMPS
	owner.get_node("AnimationPlayer").play("LAND")
	 # reset fastfall variable
	owner.fastfalling = false

func calculate_velocity(dir, curr_velocity): 
	# else, use friction to slow down to stop 
	var out = curr_velocity
	if abs(out.x): 
		if abs(out.x) > owner.friction: 
			out.x -= owner.friction if out.x > 0 else -owner.friction
		else: 
			out.x = 0
	return out 

func state_logic(delta): 
	ticker += 1
	if ticker == 2: 
		owner.get_node("AnimationPlayer").stop(false)
	if landing_frames-ticker == 2: 
		owner.get_node("AnimationPlayer").play()

func exit(): 
	ticker = 0
	# set base landing frames of 4 
	landing_frames = 4
	
func check_state(): 
	if ticker == landing_frames: 
		return "IDLE"
		
	if Input.is_action_pressed("crouch"):
		return "CROUCH"
	
	
