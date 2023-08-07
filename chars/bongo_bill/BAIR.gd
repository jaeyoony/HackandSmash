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
	owner.get_node("AnimationPlayer").play("BAIR")
	
# relies on AIR_ATTACK state to manage the ticker
func state_logic(TICKER): 
	if TICKER == 5: 
		var bair_hb = HITBOX_SCENE.instance()
		bair_hb.set_capsule(200,300)
		bair_hb.set_pos(Vector2(-210, 21))
		bair_hb.set_shape_angle(90)
		
		# DEBUG: SET HITBOXES TO INVISIBLE! (Later) 
		bair_hb.visible = true
		
		bair_hb.attack_name = "BAIR"
		bair_hb.damage = 10
		bair_hb.knockback = 0
		bair_hb.base_knockback = 20
		bair_hb.kb_growth = 100
		bair_hb.kb_angle = 45
		
		bair_hb.PLAYER_ID = owner.ID
		bair_hb.priority = 0
		bair_hb.OWNER = owner
		owner.get_node("position/body").add_child(bair_hb)
		hitboxes['0'] = bair_hb

	elif TICKER == 13: 
		if hitboxes.has('0'): 
			hitboxes['0'].queue_free()
			hitboxes.erase('0')



func exit(): 
	# delete hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


