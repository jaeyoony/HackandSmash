extends "../state_template.gd"
var ticker = 0
# Flag to indicate how many tech frames are remaining from user tech input 
var TECH_BUFFER = 0 
# how many frames a tech input allows for a tech, 
#	AKA the window for a tech after a shield input
var TECH_WINDOW_SIZE = 10

# DUMMY MODE: RANDOM TECH CHANCE
var rng = RandomNumberGenerator.new()

# records whether the tech input has been made 
var TECH_INPUT = false

func enter():
	owner.get_node("AnimationPlayer").play("TUMBLE")

func get_name(): 
	return "TUMBLE"

# TODO: check for wiggle out of tumble...? 
func process_input(dir): 
	return dir

# check for tech 
func state_logic(delta): 
	ticker += 1
	# check for tech 
	if not TECH_BUFFER and Input.is_action_just_pressed("shield") and !TECH_INPUT: 
		TECH_BUFFER = TECH_WINDOW_SIZE
		TECH_INPUT = true
	
	elif TECH_BUFFER: 
		TECH_BUFFER -= 1 
	
func exit(): 
	# reset sprite variables from wacky crazy animation 
	owner.get_node("position/body/Sprite").set_scale(Vector2(1,1))
	owner.get_node("position/body/Sprite").set_rotation(0)
	owner.TUMBLING = false
	ticker = 0
	TECH_BUFFER = 0
	TECH_INPUT = false
	return

# from tumble, can either tech, doublejump, or go into knockdown (notech) 
#	make it so you can mash/wiggle out of tumble? 
func check_state():
	if Input.is_action_just_pressed("jump") and owner.jumps: 
		owner.jumps -= 1
		return "DOUBLE_JUMP"
		
	# DUMMY MODE RANDOM TECH DEBUG
	elif owner.dummy_mode and owner.is_on_floor(): 
		var rand_call = rng.randf()
		if rand_call >= 0: 
			return "TECH"
		return "KNOCKDOWN"
		
	elif owner.is_on_floor(): 
		if Input.is_action_just_pressed("shield") or TECH_BUFFER: 
			return "TECH"
		return "KNOCKDOWN"
	return


