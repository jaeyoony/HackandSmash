extends Node

# low long the move lasts
var DURATION = 15

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("DTILT")

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
		var dtilt_hb = HITBOX_SCENE.instance()
		dtilt_hb.set_capsule(140,340)
		dtilt_hb.set_shape_angle(96)
		dtilt_hb.set_pos(Vector2(325,119))
		dtilt_hb.visible = true # DEBUG
		
		dtilt_hb.attack_name = "D_TILT"
		dtilt_hb.damage = 5
		dtilt_hb.kb_growth = 50
		dtilt_hb.kb_angle = 70
		dtilt_hb.base_knockback = 20
		
		dtilt_hb.PLAYER_ID = owner.ID
		dtilt_hb.priority = 0
		dtilt_hb.OWNER = owner
		owner.get_node("position/body").add_child(dtilt_hb)
		hitboxes[0] = dtilt_hb

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

