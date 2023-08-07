extends Node

# low long the move lasts
var DURATION = 46

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")

func enter(): 
	owner.get_node("AnimationPlayer").play("NEUTRAL_SPECIAL")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	
	var out = curr_vel
	if abs(out.x) > owner.FRICTION: 
		out.x -= owner.FRICTION if out.x > 0 else -owner.FRICTION
	else: 
		out.x = 0
		
	return out

# TODO: on frame 17, spawn in projectile
func state_logic(TICKER): 		
	# ON FRAME 24, load in BULLET
	if TICKER == 24: 
		var temp_projectile = owner.PROJECTILE_SCENE.instance()
		temp_projectile.init(owner.ID, owner.facing, owner.position)
		# add projectile as a child to the stage, not the character 
		owner.get_parent().owner.add_child(temp_projectile)


func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

