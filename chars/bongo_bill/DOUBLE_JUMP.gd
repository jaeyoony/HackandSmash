extends "../state_template.gd"
var ticker = 0
var jumped = false
const PLATFORM_BIT = 4

func get_name(): 
	return "DOUBLE_JUMP"

func enter(): 
	# reset collision w/ platforms
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	
	owner.get_node("AnimationPlayer").play("DOUBLE_JUMP")
	owner.fastfalling = false
	
func process_input(dir): 
	# read input to see which direction jump is
	# remember, double jumps can be "diagonal" (start w/ max air drift in either direction) 
	if !jumped: 
		jumped = true
		
		owner.velocity.x = owner.MAX_AIR_SPEED * dir.x
		owner.velocity.y = -owner.JUMP_FORCE
		
	return dir

func state_logic(delta): 
	ticker += 1
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >=-10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)

func exit(): 
	jumped = false 
	ticker = 0
	
func check_state(): 
	if ticker == 30: 
		return "FALL"
	elif owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("jump") and owner.jumps: 
		owner.jumps-=1
		return "DOUBLE_JUMP"
#	elif Input.is_action_just_pressed("attack") or owner._read_stick2() != Vector2.ZERO or Input.is_action_just_pressed("grab"):
	elif Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("grab") or (owner._read_stick2() != Vector2.ZERO):
		return "AIR_ATTACK"
	elif Input.is_action_just_pressed("shield") and owner.AIRDODGE_AVAILABLE: 
		return "AIRDODGE"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
