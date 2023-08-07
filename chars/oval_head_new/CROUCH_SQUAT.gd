extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return "CROUCH_SQUAT"
	
func enter(): 
	owner.get_node("AnimationPlayer").play("CROUCH_SQUAT")
	return
	
func state_logic(delta): 
	ticker += 1
	
func exit(): 
	ticker = 0

func check_state(): 
	if ticker == 5: 
		return "CROUCH"
