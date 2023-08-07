extends "../state_template.gd"
var max_speed = 100
	
func enter():
	owner.get_node("AnimationPlayer").play("WALK")
	max_speed = owner.WALK_SPEED

func process_input(dir): 
	# flip we're not facing the right way
	if dir.x * owner.facing < 0: 
		owner.get_node("position/body").set_scale(Vector2(-owner.facing,1))
		owner.facing *= -1
	return dir
	
# caps max walk speed based on strength of the input
func calculate_velocity(dir, curr_vel):
	var out = curr_vel
	if abs(dir.x) > 0.8: 
		out.x = sign(dir.x) * max_speed
	else: 
		out.x = dir.x * max_speed
	return out

func check_state(): 
	if owner.velocity.x == 0: 
		return "IDLE"
	# check for smash input, incase of dash
	elif owner.check_smash_input(): 
		return "DASH"
	elif !owner.is_on_floor(): 
		return "FALL"
	elif Input.is_action_pressed("jump"):
		return "JUMP_SQUAT"
	elif Input.is_action_just_pressed("attack"):
		return "GROUND_ATTACK"
