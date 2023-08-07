extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var ticker = 0 
# timer to indicate when to exit attack state
var timer = 0

# the type of grounded attack, i.e. FTILT, UPTILT, DASH, DSMASH, etc. 
var type = null
var hb_scene = null

var hitboxes = {}
var landing_lag = 0
var hitlag_frames = 0
var hitlag_velocity = Vector2.ZERO

# loads the hitbox scene
func _ready()-> void: 
	hb_scene = load("res://hboxes/hitbox.tscn")
	return
	
func enter():
	# figure out which attack to use 
	var stickx = owner.stick_buffer.back().x
	var sticky = owner.stick_buffer.back().y
	if(abs(stickx) < 0.1 and abs(sticky) < 0.1): 
		type = "NAIR"
		owner.get_node("AnimationPlayer").play("NAIR")
		timer = 45
		
	elif (sign(sticky) == 1 and sticky >= abs(stickx)): 
		type = "DAIR"
		owner.get_node("AnimationPlayer").play("DAIR")
		timer = 43
		landing_lag = 15
		
	else: 
		print("going into : Other attack")
	
func process_input(dir):
	return dir

# calculate the move velocity during moves: default to like
func calculate_velocity(dir, curr_vel):
	if hitlag_frames: 
		return Vector2.ZERO
			
	return curr_vel

func state_logic(delta): 
	if hitlag_frames: 
		hitlag_frames -=1 
		if hitlag_frames == 0: 
			owner.get_node("AnimationPlayer").play()
			owner.velocity = hitlag_velocity
			
	else: 
		ticker += 1
		if !owner.is_on_floor() and Input.is_action_just_pressed("crouch") and owner.velocity.y >=-10: 
			owner.fastfalling = true
		match type: 
			"NAIR": 
				if ticker == 3: 
					var nair_hb = hb_scene.instance()
					nair_hb.set_capsule(30, 100.5)
					nair_hb.set_shape_angle(70)
					nair_hb.set_pos(Vector2(50, -25))
					nair_hb.player_id = owner.ID
					nair_hb.attack_name = "NAIR"
					nair_hb.damage = 10
					nair_hb.knockback = 0
					nair_hb.base_knockback = 20
					nair_hb.kb_growth = 100
					nair_hb.kb_angle = 50
					owner.get_node("position").add_child(nair_hb)
					hitboxes[0] = nair_hb
					
				elif ticker == 32: 
					hitboxes[0].queue_free()
					hitboxes.erase(0)
					
			"DAIR": 
				if ticker == 12: 
					# set stomp hitbox
					var dair_hb = hb_scene.instance()
					dair_hb.set_capsule(50, 50)
					dair_hb.set_pos(Vector2(0, 110))
					dair_hb.player_id = owner.ID
					dair_hb.attack_name = "DAIR"
					dair_hb.damage = 20
					dair_hb.knockback = 40
					dair_hb.kb_growth = 100
					dair_hb.kb_angle = -90
					owner.get_node("position").add_child(dair_hb)
					hitboxes[0] = dair_hb
				
				elif ticker == 21: 
					hitboxes[0].queue_free()
					hitboxes.erase(0)
					
		
func exit(): 
	# delete all instances of hitboxes 
#	jab_hb.queue_free()
	for h in hitboxes: 
		hitboxes[h].queue_free()
		hitboxes.erase(h)
	ticker = 0
	timer = 0
	type = null
	owner.has_hit.clear()
	landing_lag = 0

func check_state():
	if owner.is_on_floor(): 
		return "LAND"
	elif ticker >= timer: 
#		return "IDLE"
		return "FALL"
	return
