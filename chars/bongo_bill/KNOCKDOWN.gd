extends "../state_template.gd"

var TICKER = 0
# Give a long time to wait
var TIMER = 240
# DUMMY MODE: RANDOM TECH CHANCE
var rng = RandomNumberGenerator.new()
var rng_call

func get_name(): 
	return "KNOCKDOWN"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func enter(): 
	# start grab animation
	owner.get_node("AnimationPlayer").play("KNOCKDOWN")
	
	# DUMMY MODE: determine if rolling or staying down
	rng_call = rng.randf()

func state_logic(delta):
	TICKER += 1

func check_state(): 
	if TICKER > TIMER: 
		return "IDLE"
	 
	# DUMMY MODE check, ROLLS to either direction half the time
	elif owner.dummy_mode and rng_call >= 0.5 and TICKER > 60: 
		return "ROLL"
		
	# roll to a side
	elif owner.stick_buffer.back().x > owner.walk_thr: 
		return "ROLL"

func exit(): 
	# reset counters
	TICKER = 0
	rng_call = 0
