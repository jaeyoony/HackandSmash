extends Node

# low long the move lasts
var DURATION = 24

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
# TODO: instead of loading in hitbox, load in projectile
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	

func enter(): 
	owner.get_node("AnimationPlayer").play("DOWN_SPECIAL")

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
	# FRAME 1 HITBOX
	if TICKER == 1:
		var shine_hb = HITBOX_SCENE.instance()
		shine_hb.set_circle(200)
		
		shine_hb.attack_name = "SHINE"
		shine_hb.damage = 4
		shine_hb.knockback = 20
		shine_hb.base_knockback = 90
		shine_hb.kb_growth = 50
		shine_hb.kb_angle = 90
		
		shine_hb.PLAYER_ID = owner.ID
		shine_hb.OWNER = owner
		shine_hb.priority = 0
		shine_hb.base_hitstun = 30
		owner.get_node("position/body").add_child(shine_hb)
		hitboxes['shine'] = shine_hb
		
		# make player invincible
		owner._make_invincible(4)
		


func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		print("!!!!!!!!!!! HITBOXES : ", h)
		hitboxes[h].queue_free()
		hitboxes.erase(h)

