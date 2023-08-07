extends "../state_template.gd"

# Ticker to track how many frames have elapsed 
var TICKER = 0 
# Timer to indicate how many frames the attack should last
var TIMER = 0

# the type of special attack, i.e. SIDE, UP DOWN NEUTRAL
var type = null
var HITBOX_SCENE = null

# Landing lag of the move, if move is aerial 
var landing_lag = 0

# map for currently active hitboxes 
var hitboxes = {}
# holds all attack_nodes for modularity 
var ATTACK_NODE_MAP = {}
# keep track of current attack node 
var CURRENT_ATTACK = null 

# loads the hitbox scene
func _ready()-> void: 
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	ATTACK_NODE_MAP = {
		"NEUTRAL_GROUND": $NEUTRAL, 
		"NEUTRAL_AIR": $NEUTRAL_AIR,
		"UP": $UP, 
		"SIDE": $SIDE,
		"DOWN": $DOWN,
	}
	return
	
	
func enter():
	# figure out which attack to use 
	# dash attack 
# TODO: add these checks as you add more animations 
#	if owner.prev_state == "DASH" or owner.prev_state == "RUN": 
#		CURRENT_ATTACK = ATTACK_NODE_MAP["DASH"]
#
	# up special
	if owner.stick_buffer.back().y <= -0.5 and owner.stick_buffer.back().y <= -abs(owner.stick_buffer.back().x):
		CURRENT_ATTACK = ATTACK_NODE_MAP["UP"]
	
	elif owner.stick_buffer.back().y >= 0.5 and owner.stick_buffer.back().y >= abs(owner.stick_buffer.back().x):
		CURRENT_ATTACK = ATTACK_NODE_MAP["DOWN"]
#
#	# side special
	elif abs(owner.stick_buffer.back().x) >= owner.walk_thr and abs(owner.stick_buffer.back().x) > abs(owner.stick_buffer.back().y): 
		CURRENT_ATTACK = ATTACK_NODE_MAP['SIDE']
#
#	# Down tilt
#	elif owner.stick_buffer.back().y >= 0.5 or owner.prev_state== 'CROUCH' or owner.prev_state == 'CROUCH_SQUAT': 
#		CURRENT_ATTACK = ATTACK_NODE_MAP['D_TILT']

	# neutral special
	else: 
		if owner.is_on_floor(): 
			CURRENT_ATTACK = ATTACK_NODE_MAP["NEUTRAL_GROUND"]
		else: 
			CURRENT_ATTACK = ATTACK_NODE_MAP["NEUTRAL_AIR"]
	
	# set timer, landing lag
	TIMER = CURRENT_ATTACK.DURATION
	
	# enter fcn on attack node 
	CURRENT_ATTACK.enter()
	
	
func process_input(dir):
	return dir


# call move's specific calc. velocity fcn 
func calculate_velocity(dir, curr_vel):
	if owner.HITLAG_FRAMES: 
		return Vector2.ZERO
	return CURRENT_ATTACK.calculate_velocity(dir, curr_vel, TICKER)


func state_logic(delta): 
	CURRENT_ATTACK.state_logic(TICKER)
	# check for hitlag
	if not owner.HITLAG_FRAMES: 
		TICKER += 1

	
func exit(): 
	# reset counters
	TICKER = 0
	TIMER = 0
	
	# clear hitboxes, exit
	CURRENT_ATTACK.exit()
	type = null
	owner.has_hit.clear()
	
	# reset fastfalling if landed 
	
	
func check_state():
	if TICKER > TIMER: 
		if CURRENT_ATTACK.name == 'DOWN' and owner.is_on_floor(): 
			return "CROUCH"
		if owner.is_on_floor(): 
			return "IDLE"
		elif CURRENT_ATTACK.name=="UP": 
			return "FREEFALL"
		else: 
			return "FALL"
			
	# check for air gun	
	elif CURRENT_ATTACK.name == 'NEUTRAL_AIR': 
		if owner.is_on_floor(): 
			return "LAND"
