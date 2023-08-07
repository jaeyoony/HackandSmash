extends Node

# preload the animation spritesheet..? 


# how long the move lasts
var DURATION = 49

# how many landing lag frames there are 
var LANDING_LAG = 10

# keeps track of all current hitboxes
var hitboxes = {}

# loaded hitbox scene 
var HITBOX_SCENE = null 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HITBOX_SCENE = owner.HITBOX_SCENE
	
func enter(): 
#	TICKER = 0
	owner.get_node("AnimationPlayer").play("DAIR")
	
# relies on AIR_ATTACK state to manage the ticker
func state_logic(TICKER): 
	match TICKER: 
		5: 
			var hitbox = HITBOX_SCENE.instance()
			hitbox.set_capsule(183,100)
			hitbox.set_pos(Vector2(140, 122))
			hitbox.set_shape_angle(-42.5)
			
			# DEBUG: SET HITBOXES TO INVISIBLE! (Later) 
			hitbox.visible = true
			
			hitbox.attack_name = "DAIR"
			hitbox.damage = 10
			hitbox.knockback = 0
			hitbox.base_knockback = 25
			hitbox.kb_growth = 100
			hitbox.kb_angle = -65
			
			hitbox.PLAYER_ID = owner.ID
			hitbox.priority = 0
			hitbox.OWNER = owner
			owner.get_node("position/body").add_child(hitbox)
			hitboxes[0] = hitbox
	

		25: 
			if hitboxes.has(0): 
				hitboxes[0].queue_free()
				hitboxes.erase(0)
		


func exit(): 
	# delete hitboxes
	for h in hitboxes.keys(): 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


