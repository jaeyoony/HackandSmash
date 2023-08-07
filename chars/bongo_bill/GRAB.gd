extends "../state_template.gd"

var GRAB_HITBOX_SCENE

var TICKER = 0
var TIMER = 23

# if the grab whiffed or if it successfully landed 
var GRAB_SUCCESS = false

# map of currently active hitboxes
var hitboxes = {}
# var. to point to the grabbed player
var GRAB_TARGET = null

# CONST for indicating the grab position
const GRAB_OFFSET = Vector2(303, -30)

# flag to indicate if we've performed a throw yet 
#	sets to true as soon as throw input is detected
var THROW_FLAG = false 
# after a throw is triggered, indicates the number of frames the THROWEE (one getting thrown) 
#	stays on the THROWER (this instance)'s "grab_point" 
var THROWEE_THROW_FRAMES = 0
# how long the thrower animation lasts
var THROWER_THROW_FRAMES = 0

func get_name(): 
	return "GRAB"
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GRAB_HITBOX_SCENE = load("res://hboxes/grab_hitbox.tscn")


func enter(): 
	# start grab animation
	owner.get_node("AnimationPlayer").play("GRAB")
	GRAB_SUCCESS = false
	# reset grab point
	owner.get_node("position/body/grab_point").position = GRAB_OFFSET


func state_logic(delta): 
	# grab hitbox comes out 
	if TICKER == 13: 
		var grab_hb = GRAB_HITBOX_SCENE.instance()
		grab_hb.PLAYER_ID = owner.ID
		grab_hb.set_capsule(69,165)
		grab_hb.set_shape_angle(90)
		grab_hb.set_pos(Vector2(245,-45))
		
		# attatch node to player
		owner.get_node("position/body").add_child(grab_hb)
		hitboxes['0'] = grab_hb
		
	elif TICKER > 13 and GRAB_SUCCESS and THROWEE_THROW_FRAMES == 0: 
		var dir = owner.stick_buffer.back()
		if abs(dir.x) > 0.9 and abs(dir.x) > abs(dir.y): 
			THROW_FLAG = true
			if sign(dir.x) == owner.facing: 
				# forward throw
				pass
			else: 
				# back throw
				pass
			
		# up/down throw
		elif abs(dir.y) > 0.9 and abs(dir.y) > abs(dir.x): 
			THROW_FLAG = true
			if sign(dir.y) == 1: 
				# down throw
				pass
			else: 
				# up throw
				start_throw("UP")
	
	elif THROWEE_THROW_FRAMES: 
		THROWEE_THROW_FRAMES -= 1
		# activate the throw
		if THROWEE_THROW_FRAMES == 0: 
			GRAB_TARGET.curr_state.grab_release()
			# launch the grabee
			GRAB_TARGET.velocity = Vector2(20, -500)
	
	if THROWER_THROW_FRAMES: 
		THROWER_THROW_FRAMES -= 1
			
		
	TICKER += 1

func calculate_velocity(dir, curr_velocity): 
	var out = curr_velocity
	
	# apply traction in the x-axis
	if abs(out.x) > 1*owner.FRICTION: 
		out.x -= 1*owner.FRICTION*sign(out.x)
	else: 
		out.x = 0
	return out

# sets the GRAB_TARGET variable, which stores the player inst. who got hit by the grab hitbox
func _set_grab_target(player_inst): 
	GRAB_TARGET = player_inst
	return
	

func _remove_grab_hb(): 
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


# begins the throw animation
func start_throw(throw_type): 
	# set timer
	# enter into animation
	match throw_type: 
		"UP": 
			owner.get_node("AnimationPlayer").play("UP_THROW")
			THROWEE_THROW_FRAMES = 12
			# on frame 12, enter into FALL for GRABBEE (that's when they're "thrown") 
			THROWER_THROW_FRAMES = 41
			
	# attatch grabee to throw point on animation 
	pass
	
# does all the necessary steps when a player gets grabbed: 
#	removes hitbox, sets flags, stops the grab anim. 
func trigger_grab(player_inst): 
	_remove_grab_hb()
	owner.get_node("AnimationPlayer").stop(false)
	_set_grab_target(player_inst)
	GRAB_SUCCESS = true
	


func check_state(): 
	if TICKER > TIMER and not GRAB_SUCCESS: 
		return "IDLE"
	elif THROW_FLAG and THROWER_THROW_FRAMES == 0: 
		return "IDLE"
	elif TICKER > 200: 
		# send grabbee into idle/fall as well
		if GRAB_TARGET.curr_state.name == 'GRABBED_STATE':
			GRAB_TARGET.curr_state.grab_release()
		return "IDLE"


func exit(): 
	# reset counters
	TICKER = 0
	GRAB_TARGET = null
	GRAB_SUCCESS = false
	THROWER_THROW_FRAMES = 0
	THROWEE_THROW_FRAMES = 0
	THROW_FLAG = false
	# reset grab point
	owner.get_node("position/body/grab_point").position = GRAB_OFFSET
	
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

