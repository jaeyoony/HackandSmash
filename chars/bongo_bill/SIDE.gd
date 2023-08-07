extends Node

# low long the move lasts
var DURATION = 75

# keeps track of how many frames spent grounded after falling part of move
const LANDING_LAG = 14
var GROUNDED_FRAMES = 0

# indicates whether side special is the grounded or aerial version (started in the air?) 
var GROUNDED = true

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")

func enter(): 
	# set grounded var. 
	GROUNDED = owner.is_on_floor()
	
	# flip to match input direction
	owner.flip_direction(sign(owner.stick_buffer.back().x))
	owner.get_node("AnimationPlayer").play("SIDE_SPECIAL")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	var out = curr_vel
	
	# apply gravity if not grounded version
	if TICKER < 16 and !GROUNDED: 
		out.y += owner.GRAVITY 
		
		# max fall speed
		if out.y > owner.FALL_SPEED:
			out.y = owner.FALL_SPEED
			
	# On frame 16: jump forward	
	elif TICKER == 16: 
		out = Vector2(owner.facing * 300, -85)
		
	# frame 27: knee
	# frame 37: recovery
	elif TICKER >= 41 and TICKER < 48: 
		out *= 0.9
		
	# frame 45: axe kick setup
	# frame 56: axe kick start
	elif TICKER >= 56 and TICKER < 74: 
		var WIGGLE = 40
		out = Vector2(WIGGLE*owner.stick_buffer.back().x, 500) 
		
	# frame 74: axe kick landing 
	elif TICKER == 74 and owner.is_on_floor(): 
		out = Vector2.ZERO
			
	# any other key frame, no burst of motion and friction..?
	else: 
		if abs(out.x) > owner.FRICTION: 
			out.x -= owner.FRICTION if out.x > 0 else -owner.FRICTION
		else: 
			out.x = 0

	return out

# check for grounded state after axe kick
#	if grounded for more than AXE_LANDING_LAG, then return idle state
func state_logic(TICKER): 
	if !GROUNDED and owner.is_on_floor() and TICKER < 16: 
		owner.change_state("LAND")
	# if air version, check for grounded on startup
	if GROUNDED_FRAMES >= LANDING_LAG: 
		owner.change_state("LAND")
	if TICKER > 45 and owner.is_on_floor(): 
		# enter and stay on landing pose 
		owner.get_node("AnimationPlayer").seek(1.23)
		GROUNDED_FRAMES += 1 


func exit(): 
	# reset grounded frames
	GROUNDED_FRAMES = 0
	# if on ground, reset owner's grounded properties 
	if owner.is_on_floor(): 
		owner.jumps = owner.MAX_JUMPS
		owner.AIRDODGE_AVAILABLE = true
		owner.fastfalling = false
	
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

