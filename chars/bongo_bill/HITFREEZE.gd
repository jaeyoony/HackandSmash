# state hitfreeze, aka when a character getting hit freezes for a
#	second before flying back

extends "../state_template.gd"
var ticker = 0
var HITSTUN_FRAMES = 0
var HITFREEZE_FRAMES = 0
var kb_val = 0
var exit_velocity = Vector2.ZERO

func enter():
	owner.get_node("AnimationPlayer").play("HITSTUN")
	owner.get_node("AnimationPlayer").advance(0) # advance to properly set animation now instead of next tick of animationplayer
	owner.get_node("position/body/Sprite").modulate = Color(.94, .71, .71)
	
func process_input(dir): 
	return dir

func caclulate_velocity(dir, curr_velocity):
	# just set velocity to 0 and return lol
	return Vector2(0, 0)

func state_logic(delta): 
	ticker += 1

func exit(): 
	owner.has_hit.clear()
	owner.get_node("position/body/Sprite").modulate = Color(1, 1, 1)
	HITSTUN_FRAMES = 0
	ticker = 0

func check_state():
	if ticker >= HITFREEZE_FRAMES: 
		# set exit velocity
		owner.velocity = exit_velocity
		# set hitstun frames for hitstun state
		owner.get_node("States").get_node("HITSTUN").HITSTUN_FRAMES = HITSTUN_FRAMES
		
		if kb_val > 80: 
			# set owner to tumble state
			owner.TUMBLING = true
		return "HITSTUN"
	return


