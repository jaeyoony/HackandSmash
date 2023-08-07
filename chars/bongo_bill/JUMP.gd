extends "../state_template.gd"
const PLATFORM_BIT = 4
var ticker = 0

func get_name(): 
	return "JUMP"

func enter(): 
	# reset collision w/ platforms
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	owner.get_node("AnimationPlayer").play("JUMP_ASCEND")

func state_logic(delta): 
	ticker += 1
	# check for short vs fullhop, then add vel. 
	#	 add upward force for jump
	# calculate whether its a short or full hop 
	if ticker == 1: 
		if Input.is_action_pressed("jump"):
			owner.velocity.y = -(owner.JUMP_FORCE + owner.GRAVITY)
		else:
			owner.velocity.y = -(owner.JUMP_FORCE * 0.6 + owner.GRAVITY)
	
	# fall thru platforms check
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >= -10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
	
func exit(): 
	ticker = 0
	
func check_state(): 
	if owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("shield") and owner.AIRDODGE_AVAILABLE: 
		return "AIRDODGE"
	elif ticker == 30: 
		return "FALL"	
	elif Input.is_action_just_pressed("jump") and owner.jumps > 0:
		owner.jumps -= 1
		return "DOUBLE_JUMP"
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("grab") or (owner._read_stick2() != Vector2.ZERO):
		return "AIR_ATTACK"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
