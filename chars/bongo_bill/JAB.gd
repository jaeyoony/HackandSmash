extends Node

# low long the move lasts
var DURATION = 6

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("JAB")

# given the directional input and the character's current velocity, 
# calculate the new velocity for the next frame 
func calculate_velocity(dir, curr_vel, TICKER): 
	
	# DEBUG - shouldn't be able to move during jab
	if abs(dir.x): 
		return 20*Vector2(sign(dir.x),0)
		
	return curr_vel

func state_logic(TICKER): 		
	# initial hitbox at fr 7
	if TICKER == 2: 
		var jab_hb = HITBOX_SCENE.instance()
		jab_hb.set_capsule(80,250)
		jab_hb.set_shape_angle(88)
		jab_hb.set_pos(Vector2(183,-54))
		jab_hb.visible = true # DEBUG
		
		jab_hb.attack_name = "JAB"
		jab_hb.damage = 5
		jab_hb.kb_growth = 50
		jab_hb.kb_angle = 45
		jab_hb.base_knockback = 20
		
		jab_hb.PLAYER_ID = owner.ID
		jab_hb.OWNER = owner 
		jab_hb.priority = 0
		owner.get_node("position/body").add_child(jab_hb)
		hitboxes['jab'] = jab_hb

	# remove active hitbox on f5
	elif TICKER == 5: 
		if 'jab' in hitboxes: 
			hitboxes['jab'].queue_free()
			hitboxes.erase('jab')
		

func exit(): 
	# remove hitboxes hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)

