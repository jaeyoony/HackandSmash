extends "../state_template.gd"
const PLATFORM_BIT = 4

# length of the tech animation
const TECH_LENGTH = 24
const TECH_ROLL_SPEED = 130
var TICKER = 0

# indicates if the tech is forward or backwards from character's facing direction
# -1 = backwards/AWAY from character's facing direction
# 0 = neutral, tech in place
# +1 = forwards/TOWARDS the direction the player is facing
var TECH_TYPE = 0


func get_name(): 
	return "TECH"


func enter(): 
	owner.get_node("AnimationPlayer").play("TECH")
	
	# if dummy mode, pick a random direction
	if owner.dummy_mode: 
		var rng_call = owner.rng.randf()
		if rng_call < 0.33: 
			TECH_TYPE = 1
		elif rng_call >= 0.66: 
			TECH_TYPE = -1
#			owner.get_node("position/body").set_scale(Vector2(-owner.facing, 1))
		else: 
			TECH_TYPE = 0
				
	# for backwards roll, flip model for animation but don't flip when we get there
	# for forwards roll, don't flip model for animation but change facing after
	elif owner.stick_buffer.back().x > owner.walk_thr: 
		
		if sign(owner.stick_buffer.back().x) != owner.facing: 
			TECH_TYPE = -1
			owner.get_node("position/body").set_scale(Vector2(-owner.facing, 1))
		else: 
			TECH_TYPE = 1
		
	else: 
		TECH_TYPE = 0
	
	
func process_input(dir): 
	return dir


func state_logic(delta): 
	TICKER += 1 
	return 


# calculate the move velocity during moves:
func calculate_velocity(dir, curr_vel):
	if TICKER < 18: 
		if owner.get_node("position/body/edge_detector").is_colliding(): 
			if TECH_TYPE == -1: 
				return Vector2(-owner.facing*TECH_ROLL_SPEED, 0)
			elif TECH_TYPE == 1: 
				return Vector2(owner.facing*TECH_ROLL_SPEED, 0)
	return Vector2.ZERO
	
	
func check_state(): 
	if TICKER > TECH_LENGTH: 
		return "IDLE"

func exit(): 
	TECH_TYPE = 0
	TICKER = 0

