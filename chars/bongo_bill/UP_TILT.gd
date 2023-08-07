extends Node

# low long the move lasts
var DURATION = 9

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("UP_TILT")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	var out = curr_vel
	if abs(out.x) > owner.FRICTION: 
		out.x = sign(curr_vel.x)*(abs(out.x) - owner.FRICTION)
	else: 
		out.x = 0
	return out

func state_logic(TICKER): 		
	# initial hitbox at fr 7
	if TICKER == 2: 
		var uptilt_hb = HITBOX_SCENE.instance()
		uptilt_hb.set_capsule(90,300)
		uptilt_hb.set_shape_angle(17.5)
		uptilt_hb.set_pos(Vector2(175,-165))
		uptilt_hb.visible = true # DEBUG
		
		uptilt_hb.attack_name = "UP_TILT"
		uptilt_hb.damage = 5
		uptilt_hb.kb_growth = 50
		uptilt_hb.kb_angle = 70
		uptilt_hb.base_knockback = 20
		
		uptilt_hb.PLAYER_ID = owner.ID
		uptilt_hb.OWNER = owner
		uptilt_hb.priority = 0
		owner.get_node("position/body").add_child(uptilt_hb)
		hitboxes[0] = uptilt_hb

	# remove active hitbox on f5
	elif TICKER == 5: 
		for h in hitboxes: 
			hitboxes[h].queue_free()
			hitboxes.erase(h)
#		hitboxes[0].queue_free()
#		hitboxes.erase(0)

func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

