extends Node

# low long the move lasts
var DURATION = 32

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("DASH_ATTACK")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	# inital boost in speed
	if TICKER == 1: 
		return Vector2(owner.facing*owner.DASH_SPEED*1.2, curr_vel.y)
	elif TICKER > 7:
		if abs(curr_vel.x) > owner.FRICTION: 
			curr_vel.x -= owner.FRICTION if curr_vel.x > 0 else -owner.FRICTION
		else: 
			curr_vel.x = 0
	return curr_vel

func state_logic(TICKER): 		
	# initial hitbox at fr 7
	if TICKER == 5: 
		var strong_dash_hb = HITBOX_SCENE.instance()
		strong_dash_hb.set_rect(130,200)
		strong_dash_hb.set_pos(Vector2(64,0))
		strong_dash_hb.visible = true
		
		strong_dash_hb.attack_name = "DASH"
		strong_dash_hb.damage = 10
		strong_dash_hb.kb_growth = 90
		strong_dash_hb.kb_angle = 70
		strong_dash_hb.base_knockback = 22
		
		strong_dash_hb.PLAYER_ID = owner.ID
		strong_dash_hb.OWNER = owner
		strong_dash_hb.priority = 0
		owner.get_node("position/body").add_child(strong_dash_hb)
		hitboxes['strong'] = strong_dash_hb
		
	# weak hitbox at 10 
	elif TICKER == 10: 
		if 'strong' in hitboxes:  
			hitboxes['strong'].queue_free()
			hitboxes.erase('strong')
		
		var weak_dash_hb = HITBOX_SCENE.instance()
		weak_dash_hb.set_rect(100,100)
		weak_dash_hb.set_pos(Vector2(80,64))
		weak_dash_hb.visible = true
		
		weak_dash_hb.attack_name = "DASH"
		weak_dash_hb.damage = 10
		weak_dash_hb.kb_growth = 30
		weak_dash_hb.kb_angle = 70
		weak_dash_hb.base_knockback = 20
		
		weak_dash_hb.PLAYER_ID = owner.ID
		weak_dash_hb.OWNER = owner 
		weak_dash_hb.priority = 0
		owner.get_node("position/body").add_child(weak_dash_hb)
		hitboxes['weak'] = weak_dash_hb
		
	# remove active hitbox on f16
	elif TICKER == 17: 
		if hitboxes.has('weak'): 
			hitboxes['weak'].queue_free()
			hitboxes.erase('weak')
		
		

func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

