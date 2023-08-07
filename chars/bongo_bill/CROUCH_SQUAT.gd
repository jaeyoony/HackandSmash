extends "../state_template.gd"
var ticker = 0
const PLATFORM_BIT = 4

func get_name(): 
	return "CROUCH_SQUAT"
	
func enter(): 
	owner.get_node("AnimationPlayer").play("CROUCH_SQUAT")
	return
	
func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	if abs(curr_velocity.x) > owner.FRICTION: 
		out.x = curr_velocity.x - sign(owner.FRICTION)
	else: 
		out.x = 0
	return out

func state_logic(delta): 
	# disable platform collision for falling thru platforms while grounded, if smash input
	if owner.check_smash_input('y'): 
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
	ticker += 1
	
func exit(): 
	ticker = 0

func check_state(): 
	if ticker == 4: 
		return "CROUCH"
	elif !owner.is_on_floor(): 
		return "FALL"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
