extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return("DASH_TURN")

func enter():
	owner.get_node("AnimationPlayer").play("DASH_TURN")
	
func process_input(dir): 
	return dir

func caclulate_velocity(dir, curr_velocity):
	# just set velocity to 0 and return lol
	return Vector2(0, curr_velocity.y)

func state_logic(delta): 
	ticker += 1

func exit(): 
	ticker = 0

func check_state(): 
	var x_in = owner.stick_buffer.back().x
	# you can do pretty much everything out of a pivot, so...
	if !owner.is_on_floor(): 
		owner.jumps-= 1
		return "FALL"
		
	# 1 frame animation, so check upper bound by 2
	elif ticker >= 1: 
		owner.flip_direction(sign(x_in))
		# check for smash input / dash in other direction 
		if sign(x_in) == owner.facing and abs(x_in) > 0.1: 
			return "DASH"
		# else, pivot into idle
		else: 
			return "IDLE"
	return


