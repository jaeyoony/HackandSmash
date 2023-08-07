extends "../state_template.gd"
var ticker = 0
var hs_frames = 0

func enter():
	owner.get_node("AnimationPlayer").play("HITSTUN")
	
func process_input(dir): 
	return dir

#func caclulate_velocity(dir, curr_velocity):
#	return

func state_logic(delta): 
	ticker += 1

func exit(): 
	owner.tumbling = false
	ticker = 0
	return

func check_state():
		
	if ticker >= hs_frames-2: 
		owner.get_node("AnimationPlayer").play("HITSTUN_END")
		
	if ticker >= hs_frames: 
		if owner.tumbling: 
			print("SHOULD GO TO TUMBLE POST HITSTUN")
		
		if owner.is_on_floor(): 
			return "IDLE"
		return "FALL"
	return


