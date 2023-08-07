extends Node
# how long the move lasts
var DURATION = 40

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
#	TICKER = 0
	owner.get_node("AnimationPlayer").play("FAIR")
	
# relies on AIR_ATTACK state to manage the ticker
func state_logic(TICKER): 
	match TICKER: 
		
		12: 
			# weak hitbox
			var weak_hitbox = HITBOX_SCENE.instance()
			weak_hitbox.set_capsule(140,85)
			weak_hitbox.set_pos(Vector2(33, -90))
			
			# DEBUG: SET HITBOXES TO INVISIBLE! (Later) 
			weak_hitbox.visible = true
			
			weak_hitbox.attack_name = "FAIR"
			weak_hitbox.damage = 10
			weak_hitbox.knockback = 0
			weak_hitbox.base_knockback = 20
			weak_hitbox.kb_growth = 80
			weak_hitbox.kb_angle = 45
			
			# attach & save hitbox
			weak_hitbox.PLAYER_ID = owner.ID
			weak_hitbox.priority = 0
			weak_hitbox.OWNER = owner 
			owner.get_node("position/body").add_child(weak_hitbox)
			hitboxes[0] = weak_hitbox
			
			# strong (spike) hitbox
			var strong_hitbox = HITBOX_SCENE.instance()
			strong_hitbox.set_circle(124)
			strong_hitbox.set_pos(Vector2(210, -163))
			
			strong_hitbox.attack_name = "FAIR"
			strong_hitbox.damage = 25
			strong_hitbox.knockback = 20
			strong_hitbox.base_knockback = 20
			strong_hitbox.kb_growth = 90
			strong_hitbox.kb_angle = 45
			
			# DEBUG: SET HITBOXES TO INVISIBLE! 
			strong_hitbox.visible = true
			
			# attach & save hitbox
			strong_hitbox.PLAYER_ID = owner.ID
			strong_hitbox.priority = 1
			strong_hitbox.OWNER = owner 
			owner.get_node("position/body").add_child(strong_hitbox)
			hitboxes[1] = strong_hitbox
			
		16: 
			if hitboxes.has(1): 
				hitboxes[1].kb_angle = -70
				hitboxes[1].set_color(Color(0.3, 1, 0.3))
	
		19: 
			if hitboxes.has(0): 
				hitboxes[0].set_capsule(154,100)
				hitboxes[0].set_pos(Vector2(33,-65))
			
			if hitboxes.has(1): 
				hitboxes[1].set_circle(155)
				hitboxes[1].set_pos(Vector2(207, 111))
	
		25: 
			# clear all hitboxes
			for h in hitboxes.keys(): 
				hitboxes[h].queue_free()
				hitboxes.erase(h)
		


func exit(): 
	# delete hitboxes
	for h in hitboxes.keys(): 
		hitboxes[h].queue_free()
		hitboxes.erase(h)


