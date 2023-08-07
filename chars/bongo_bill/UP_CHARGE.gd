extends Node

# low long the move lasts
var DURATION = 21

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")

func enter(): 
	owner.get_node("AnimationPlayer").play("UP_SPECIAL_CHARGE")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	# slow down to 0 in both horizontal and vertical speeds 
	var out = curr_vel
	if abs(out.x) > owner.FRICTION: 
		out.x -= owner.FRICTION if out.x > 0 else -owner.FRICTION
	else: 
		out.x = 0
		
	return out


func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

