extends "../state_template.gd"
var ticker = 0
var hs_frames = 0
var hlag_frames = 0
var kb_val = 0
var exit_velocity = Vector2.ZERO

func enter():
	owner.get_node("AnimationPlayer").play("HIT_FREEZE")
	
func process_input(dir): 
	return dir

func caclulate_velocity(dir, curr_velocity):
	# just set velocity to 0 and return lol
	return Vector2(0, 0)

func state_logic(delta): 
	ticker += 1

func exit(): 
	owner.has_hit.clear()
	hs_frames = 0
	ticker = 0

func check_state():
		
	if ticker >= hlag_frames: 
		# set exit velocity
		owner.velocity = exit_velocity
		
		# set hitstun frames for hitstun state
		owner.get_node("States").get_node("HITSTUN").hs_frames = hs_frames
		
		if kb_val > 80: 
			# set owner to tumble state
			owner.tumbling = true
			
		return "HITSTUN"
	return


