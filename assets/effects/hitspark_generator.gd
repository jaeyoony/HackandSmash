extends Node2D

# generic class for particle generator for hitsparks
# to be imported and used within the stage scene

# bool. indicating whether node is on or off, default to false
var ACTIVE = false
# how long to leave the node on each time it is activated
var DURATION = 4
# keeps track of elapsed frames 
var TICKER = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# check to see if its time to turn off 
	if ACTIVE and TICKER >= DURATION: 
		deactivate()
	TICKER += 1

func set_pos(pos_vec): 
	$Particles2D.set_position(pos_vec)

# Sets the number of active frames that this node will output
# default is 4 frames (for explosion effect) 
func set_duration(frames): 
	if frames > 0: 
		DURATION = frames

func activate(): 
	$Particles2D.emitting = true
	ACTIVE = true
	TICKER = 0

func deactivate(): 
	$Particles2D.emitting = false
	ACTIVE = false
	TICKER = 0
	
func set_particle_texture(new_texture): 
	$Particles2D.set_texture(new_texture)




