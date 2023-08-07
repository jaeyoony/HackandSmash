extends Node
# how long the move lasts
var DURATION = 28

# how many landing lag frames there are 
var LANDING_LAG = 10

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("UP_AIR")
	
# relies on AIR_ATTACK state to manage the ticker
func state_logic(TICKER): 
	# initial hitbox at fr 7
	if TICKER == 5: 
		var upair_hb = HITBOX_SCENE.instance()
		upair_hb.set_capsule(120,200)
		upair_hb.set_pos(Vector2(253,65))
		upair_hb.set_shape_angle(-55)
		
		# DEBUG: SET HITBOXES TO INVISIBLE! (Later) 
		upair_hb.visible = true
		
		upair_hb.attack_name = "UP_AIR"
		upair_hb.damage = 13
		upair_hb.knockback = 0
		upair_hb.base_knockback = 10
		upair_hb.kb_growth = 100
		upair_hb.kb_angle = 65
		
		upair_hb.PLAYER_ID = owner.ID
		upair_hb.priority = 0
		upair_hb.OWNER = owner
		owner.get_node("position/body").add_child(upair_hb)
		hitboxes['0'] = upair_hb

	elif TICKER == 7: 
		hitboxes['0'].set_pos(Vector2(226,-180))
		hitboxes['0'].set_shape_angle(-100)
	elif TICKER == 10: 
		hitboxes['0'].set_pos(Vector2(50,-330))
		hitboxes['0'].set_shape_angle(10)
	elif TICKER == 13: 
		hitboxes['0'].set_pos(Vector2(-225,-62))
		hitboxes['0'].set_shape_angle(-68)
		
	# remove the hitbox
	elif TICKER == 18: 
		if hitboxes.has('0'): 
			hitboxes['0'].queue_free()
			hitboxes.erase('0')
		


func exit(): 
	# delete hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


