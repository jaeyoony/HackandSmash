extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return("RUN_STOP")

func enter():
	owner.get_node("AnimationPlayer").play("RUN_STOP")
	
#func process_input(dir): 
#	dir.x = 0
#	return dir

func state_logic(delta): 
	ticker += 1

func exit(): 
	ticker = 0

func check_state(): 
	if !owner.is_on_floor(): 
		owner.jumps -= 1
		return "FALL"
	# 15 frames long
	if(ticker == 16):
		# check if run is held in the opposite direction
		if owner.facing *owner.stick_buffer.back().x < 0 and abs(owner.stick_buffer.back().x) >= owner.dash_thr:
			# turn around and go
			owner.facing = sign(owner.stick_buffer.back().x)
			owner.get_node("position/body").set_scale(Vector2(owner.facing,1))
			return "RUN"
		return "IDLE"
	return


