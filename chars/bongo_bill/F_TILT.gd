extends Node

# low long the move lasts
var DURATION = 28

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("FTILT")

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
	if TICKER == 7: 
		var ftilt_hb = HITBOX_SCENE.instance()
		ftilt_hb.set_capsule(100,250)
		ftilt_hb.set_shape_angle(90)
		ftilt_hb.set_pos(Vector2(255,-25))
		ftilt_hb.visible = true # DEBUG
		
		ftilt_hb.attack_name = "FTILT"
		ftilt_hb.damage = 5
		ftilt_hb.kb_growth = 50
		ftilt_hb.kb_angle = 70
		ftilt_hb.base_knockback = 20
		
		
		ftilt_hb.PLAYER_ID = owner.ID
		ftilt_hb.priority = 0
		ftilt_hb.OWNER = owner
		owner.get_node("position/body").add_child(ftilt_hb)
		hitboxes[0] = ftilt_hb

	# remove active hitbox on frame 15
	elif TICKER == 15: 
		for h in hitboxes: 
			hitboxes[h].queue_free()
			hitboxes.erase(h)

func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

