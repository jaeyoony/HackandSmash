extends "../state_template.gd"
var ticker = 0
var HITSTUN_FRAMES = 0
# var to keep track of last y input before bouncing
var last_y = 0

# flag to indicate whether hitstun started in the air or on the ground
var GROUNDED = false

func enter():
	GROUNDED = owner.is_on_floor()
	
func process_input(dir): 
	return dir


func state_logic(delta): 
	# if in hitstun and hit the floor, then bounce
	if owner.is_on_floor() and not GROUNDED: 
		GROUNDED = true 
		# set vertical velocity to vertical
		owner.velocity.x *= 0.8
		owner.velocity.y = -0.8 * last_y
		
	else: 
		last_y = owner.velocity.y
	ticker += 1

func exit(): 
	owner.TUMBLING = false
	HITSTUN_FRAMES = 0
	ticker = 0
	# reset grounded vars
	GROUNDED = true
	last_y = 0
	
	return

func check_state():
	if ticker >= HITSTUN_FRAMES: 
		if owner.TUMBLING: 
			return "TUMBLE"
		if owner.is_on_floor(): 
			return "LAND"
		return "FALL"
	return


