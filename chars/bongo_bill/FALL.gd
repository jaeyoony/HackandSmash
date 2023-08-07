extends "../state_template.gd"
const PLATFORM_BIT = 4

func get_name(): 
	return "FALL"


func enter(): 
	owner.get_node("AnimationPlayer").play("FALL")

	
func process_input(dir): 
	return dir


func state_logic(delta): 
	# check for fastfalling/falling thru platforms input 
	if !owner.fastfalling and !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >= -10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
	
	
func check_state(): 
	if owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("jump") and owner.jumps > 0:
		owner.jumps -= 1
		return "DOUBLE_JUMP"
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("grab") or (owner._read_stick2() != Vector2.ZERO):
		return "AIR_ATTACK"
	elif Input.is_action_just_pressed("shield") and owner.AIRDODGE_AVAILABLE: 
		return "AIRDODGE"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
