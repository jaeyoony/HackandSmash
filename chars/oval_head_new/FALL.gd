extends "../state_template.gd"
func get_name(): 
	return "FALL"

func enter(): 
	owner.get_node("AnimationPlayer").play("FALL")
	
func process_input(dir): 
	return dir

func state_logic(delta): 
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch") and owner.velocity.y >=-10: 
		owner.fastfalling = true
		
	
func check_state(): 
	if owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("jump") and owner.jumps > 0:
		owner.jumps -= 1
		return "DOUBLE_JUMP"
	elif Input.is_action_just_pressed("attack"): 
		return "AIR_ATTACK"
