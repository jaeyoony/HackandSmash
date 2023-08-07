extends "../state_template.gd"
var ticker = 0

func get_name(): 
	return "JUMP"

func enter(): 
	owner.get_node("AnimationPlayer").play("JUMP_ASCEND")

func state_logic(delta): 
	ticker += 1
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch") and owner.velocity.y >= -10: 
		owner.fastfalling = true
	
func exit(): 
	ticker = 0
	
func check_state(): 
	if ticker == 30: 
		return "FALL"
	
	elif owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("jump") and owner.jumps > 0:
		owner.jumps -= 1
		return "DOUBLE_JUMP"
	elif Input.is_action_just_pressed("attack"): 
		return "AIR_ATTACK"
	
