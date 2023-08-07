extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var TICKER = 0 
# timer to indicate when to exit attack state
var TIMER = 0

# the type of aerial, i.e. NAIR, FAIR, etc. 
var TYPE = null
var HITBOX_SCENE = null

# preload attacks
#const HITSPARK_GENERATOR = preload("res://assets/effects/hitspark_generator.tscn")
const DAIR_NODE = preload("res://chars/bongo_bill/DAIR.gd")

# dict to hold curr. active hitboxes
var hitboxes = {}
# dict to hold all attack node states 
var ATTACK_NODE_MAP = {}
var CURRENT_ATTACK = null

var landing_lag = 0

const PLATFORM_BIT = 4

func get_name(): 
	return "AIR_ATTACK"
	
# loads the hitbox scene
func _ready()-> void: 
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	ATTACK_NODE_MAP = {
		"NAIR": $NAIR, 
		"UP_AIR": $UP_AIR, 
		"BAIR": $BAIR, 
		"FAIR": $FAIR, 
		"DAIR": $DAIR,
	}
	return
	
func enter():
	# reset platform collision
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	
	# figure out which attack to use 
	var stickx = owner.stick_buffer.back().x
	var sticky = owner.stick_buffer.back().y
	
#	var stick2 = owner._read_stick2()
	var stick2 = Vector2(
		Input.get_action_strength("stick2_right") - Input.get_action_strength("stick2_left"), 
		-Input.get_action_strength("stick2_up") + Input.get_action_strength("stick2_down")
	)
	
	# return a cardinal direction	
	if abs(stick2.x) > abs(stick2.y) and abs(stick2.x) > 0.1: 
		stick2 = Vector2(sign(stick2.x), 0)
	elif abs(stick2.y) > abs(stick2.x) and abs(stick2.y) > 0.1: 
		stick2 = Vector2(0, sign(stick2.y))
	else: 
		stick2 = Vector2.ZERO
	
	
	# check stick2 input, those get priority 
	if stick2 != Vector2.ZERO: 
		# adjust x dir. to be rel. to player, not just left/right
		stick2.x = stick2.x * owner.facing
		match stick2: 
			# foward 
			Vector2(1, 0): 
				TYPE = 'FAIR'
				CURRENT_ATTACK = ATTACK_NODE_MAP['FAIR']
			# back
			Vector2(-1, 0):
				TYPE = "BAIR"
				CURRENT_ATTACK = ATTACK_NODE_MAP['BAIR']
			# up 
			Vector2(0,-1): 
				TYPE = "UP_AIR"
				CURRENT_ATTACK = ATTACK_NODE_MAP['UP_AIR']
			# down
			Vector2(0, 1): 
				TYPE = "DAIR"
				CURRENT_ATTACK = ATTACK_NODE_MAP['DAIR'] 
				
	# check for ZAIR, for instant NAIR: 
	elif Input.is_action_just_pressed("grab"): 
		TYPE = "NAIR"
		CURRENT_ATTACK = ATTACK_NODE_MAP['NAIR']
	else: 
		if(abs(stickx) < 0.1 and abs(sticky) < 0.1): 
			# debug: printing arial attack state
			TYPE = "NAIR"
			CURRENT_ATTACK = ATTACK_NODE_MAP['NAIR']
		
		elif (sign(sticky) == -1) and abs(sticky) >= abs(stickx): 
			TYPE = "UP_AIR"
			CURRENT_ATTACK = ATTACK_NODE_MAP['UP_AIR']
		
		elif(abs(stickx) > 0.1) and stickx*owner.facing < 0: 
			TYPE = "BAIR"
			CURRENT_ATTACK = ATTACK_NODE_MAP['BAIR']
		
		elif(abs(stickx) > 0.1) and stickx*owner.facing >=0: 
			TYPE = 'FAIR'
			CURRENT_ATTACK = ATTACK_NODE_MAP['FAIR']
			
		elif (abs(sticky) > 0.1 and sign(sticky) == 1 and sticky >= abs(stickx)): 
			TYPE = "DAIR"
			CURRENT_ATTACK = ATTACK_NODE_MAP['DAIR'] 
			
	landing_lag = CURRENT_ATTACK.LANDING_LAG
	TIMER = CURRENT_ATTACK.DURATION
	CURRENT_ATTACK.enter()
	
	
func process_input(dir):
	return dir
#
func state_logic(delta): 
	# check for fastfall during aerial
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >= -10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)

	CURRENT_ATTACK.state_logic(TICKER)
	if not owner.HITLAG_FRAMES: 
		TICKER+=1

		
func exit(): 
	TICKER = 0
	TIMER = 0
	CURRENT_ATTACK.exit()
	TYPE = null
	owner.has_hit.clear()
	landing_lag = 0

func check_state():
	if owner.is_on_floor(): 
		return "LAND"
	elif TICKER >= TIMER: 
		return "FALL"
