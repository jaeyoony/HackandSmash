extends Node
# how long the move lasts
var DURATION = 32

# how many landing lag frames there are 
var LANDING_LAG = 5

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = load("res://hboxes/hitbox.tscn")
	
func enter(): 
	owner.get_node("AnimationPlayer").play("NAIR")
	
# relies on AIR_ATTACK state to manage the ticker
func state_logic(TICKER): 
	# initial hitbox at fr 7
	if TICKER == 6: 
		var nair_hb = HITBOX_SCENE.instance()
		nair_hb.set_circle(250)
#		nair_hb.set_pos(Vector2(56,120))
		
		# DEBUG: SET HITBOXES TO INVISIBLE! (Later) 
		nair_hb.visible = true
		
		nair_hb.attack_name = "NAIR"
		nair_hb.damage = 10
		nair_hb.knockback = 0
		nair_hb.base_knockback = 20
		nair_hb.kb_growth = 100
		nair_hb.kb_angle =45
		
		nair_hb.PLAYER_ID = owner.ID
		nair_hb.OWNER = owner
		nair_hb.priority = 0
		owner.get_node("position/body").add_child(nair_hb)
		hitboxes['0'] = nair_hb

	elif TICKER == 24: 
		if hitboxes.has('0'): 
			hitboxes['0'].queue_free()
			hitboxes.erase('0')
		


func exit(): 
	# delete hitboxes
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


