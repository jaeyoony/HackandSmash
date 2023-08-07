extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var ticker = 0 
var is_getup = false

func get_name(): 
	return "BLOCK"
	
func enter():
	ticker = 0
	owner.get_node("AnimationPlayer").play("CROUCH_IDLE")
	
func state_logic(delta): 
	if is_getup:
		ticker += 1

func process_input(dir): 
	dir.x = 0
	return dir
	
func exit(): 
	ticker = 0
	is_getup = false

func check_state():
	if is_getup and ticker == 6:
		return "IDLE"
	elif not owner.is_on_floor(): 
		owner.jumps -=1
		return "FALL"
	elif Input.is_action_pressed("jump"): 
		return "JUMP_SQUAT"
	elif not Input.is_action_pressed("crouch"):
		is_getup = true
		owner.get_node("AnimationPlayer").play("CROUCH_GETUP")
	return
