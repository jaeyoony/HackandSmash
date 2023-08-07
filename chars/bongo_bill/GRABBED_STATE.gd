extends "../state_template.gd"

var GRAB_HITBOX_SCENE

var TICKER = 0
var THROW_TYPE = 0

var GRABBER = null
# indicates if grab has been released yet or not
var GRAB_RELEASE = false

# map of currently active hitboxes
var hitboxes = {}

func get_name(): 
	return "GRABBED_STATE"
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func enter(): 
	# start grab animation
	owner.get_node("AnimationPlayer").play("GRABBED")
	
func turn_and_snap(): 
	if GRABBER != null and GRABBER.curr_state.name == 'GRAB': 
		# set pos
#		owner.position = GRABBER.position + (GRABBER.CHAR_SPRITE_SCALE.x * GRABBER.curr_state.GRAB_OFFSET * GRABBER.facing)
		owner.position = GRABBER.position + (GRABBER.CHAR_SPRITE_SCALE.x * GRABBER.get_node("position/body/grab_point").position * GRABBER.facing)
		# flip to face 
		owner.flip_direction(-sign(GRABBER.facing))


func calculate_velocity(dir, curr_velocity): 
	if not GRAB_RELEASE: 
		return Vector2.ZERO
	return curr_velocity

# sets the throw type to play after the throw anim. 
func set_throw_type(type): 
	THROW_TYPE = type


func state_logic(delta): 
	TICKER += 1
	if GRABBER != null and GRABBER.curr_state.name == 'GRAB' and !GRAB_RELEASE: 
#		owner.position = GRABBER.position + (GRABBER.CHAR_SPRITE_SCALE.x * GRABBER.curr_state.GRAB_OFFSET * GRABBER.facing)
		owner.position = GRABBER.position + (GRABBER.CHAR_SPRITE_SCALE.x * GRABBER.get_node("position/body/grab_point").position * GRABBER.facing)
	
# sets the GRABBER var to point to the character who grabbed THIS character
func set_grabber(char_inst): 
	GRABBER = char_inst

func grab_release(): 
	GRAB_RELEASE = true


func check_state(): 
	if GRAB_RELEASE: 
		return "TUMBLE"
	pass
	

func exit(): 
	# reset counters
	TICKER = 0
	GRABBER = null
	GRAB_RELEASE = false
	THROW_TYPE = null
	
