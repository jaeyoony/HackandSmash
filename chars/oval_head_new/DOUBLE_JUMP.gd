extends "../state_template.gd"
var ticker = 0
var jumped = false

func get_name(): 
	return "DOUBLE_JUMP"

func enter(): 
	owner.get_node("AnimationPlayer").play("DOUBLE_JUMP")
	owner.fastfalling = false
	
func process_input(dir): 
	if !jumped: 
		jumped = true
		print(dir)
		# check for flip 
		if dir.x * owner.facing < 0: 
			owner.get_node("position/body").set_scale(Vector2(-owner.facing, 1))
			owner.facing *= -1
#			# set horizontal velocity to 0
#			owner.velocity.x = 0
			
#		return Vector2(dir.x, -1.0)
		owner.velocity.x = owner.MAX_AIR_SPEED * dir.x
		owner.velocity.y = -owner.JUMP_FORCE
		
	return dir

func state_logic(delta): 
	ticker += 1
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch") and owner.velocity.y >=-10: 
		owner.fastfalling = true

func exit(): 
	jumped = false 
	ticker = 0
	
func check_state(): 
	if ticker == 30: 
		return "FALL"
	elif owner.is_on_floor(): 
		return "LAND"
	elif Input.is_action_just_pressed("attack"): 
		return "AIR_ATTACK"
	
