extends Node

const PLATFORM_BIT = 4

# low long the move lasts
var DURATION = 32

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 


# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")

func enter(): 
	owner.get_node("AnimationPlayer").play("NEUTRAL_SPECIAL_AIR")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	return curr_vel

# TODO: on frame 17, spawn in projectile
func state_logic(TICKER): 
	# check for fastfalling/falling thru platforms input 
	if !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >=-10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
		
	if TICKER == 14: 
		var temp_projectile = owner.PROJECTILE_SCENE.instance()
		temp_projectile.init(owner.ID, owner.facing, owner.position)
		# add projectile as a child to the stage, not the character 
		owner.get_parent().owner.add_child(temp_projectile)
	

func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

