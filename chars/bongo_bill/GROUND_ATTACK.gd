extends "../state_template.gd"

# Ticker to track how many frames have elapsed 
var TICKER = 0 
# Timer to indicate how many frames the attack should last
var TIMER = 0

# the type of grounded attack, i.e. FTILT, UPTILT, DASH, DSMASH, etc. 
var type = null
var HITBOX_SCENE = null

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
		"DASH": $DASH_ATTACK, 
		"JAB": $JAB, 
		"UP_TILT": $UP_TILT, 
		"F_TILT": $F_TILT, 
		"D_TILT": $D_TILT,
	}
	return
	
	
func enter():
	# figure out which attack to use 
	# dash attack 
	if owner.prev_state == "DASH" or owner.prev_state == "RUN": 
		CURRENT_ATTACK = ATTACK_NODE_MAP["DASH"]
		
	# uptilt
	elif owner.stick_buffer.back().y <= -0.5 and owner.stick_buffer.back().y < -abs(owner.stick_buffer.back().x):
		CURRENT_ATTACK = ATTACK_NODE_MAP["UP_TILT"]
	
	# ftilt
	elif abs(owner.stick_buffer.back().x) >= owner.walk_thr and abs(owner.stick_buffer.back().x) > abs(owner.stick_buffer.back().y): 
		CURRENT_ATTACK = ATTACK_NODE_MAP['F_TILT']
	
	# Down tilt
	elif owner.stick_buffer.back().y >= 0.5 or owner.prev_state== 'CROUCH' or owner.prev_state == 'CROUCH_SQUAT': 
		CURRENT_ATTACK = ATTACK_NODE_MAP['D_TILT']
		
	# jab, SHOULD CHECK @ END 
	elif abs(owner.stick_buffer.back().x) <= owner.walk_thr: 
		CURRENT_ATTACK = ATTACK_NODE_MAP["JAB"] 
	
	else: 
		CURRENT_ATTACK = ATTACK_NODE_MAP["JAB"]
	
	# set timer
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

func check_state():
	if TICKER > TIMER: 
		return "IDLE"
