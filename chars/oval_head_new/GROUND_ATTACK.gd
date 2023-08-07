extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var ticker = 0 
# timer to indicate when to exit attack state
var timer = 0

# the type of grounded attack, i.e. FTILT, UPTILT, DASH, DSMASH, etc. 
var type = null
var hb_scene = null

var hitboxes = {}

# how many frames of hitstun to be in after landing a hit
# is set by the hurtbox, so just listen
var hitlag_frames = 0
var hitlag_velocity = Vector2.ZERO

# loads the hitbox scene
func _ready()-> void: 
	hb_scene = load("res://hboxes/hitbox.tscn")
	return
	
func enter():
	# figure out which attack to use 
	if owner.prev_state == "DASH" or owner.prev_state == "RUN": 
		timer = 36
		type = "DASH"
		owner.get_node("AnimationPlayer").play("DASH_ATTACK")
	
	elif abs(owner.stick_buffer.back().x) < owner.walk_thr: 
		timer = 11
		type = "JAB"
		owner.get_node("AnimationPlayer").play("JAB")
	
	else: 
		print("going into : Other attack")
	
	
func process_input(dir):
	return dir

# calculate the move velocity during moves: default to like
func calculate_velocity(dir, curr_vel):
	if hitlag_frames: 
		return Vector2.ZERO
	match type: 
		"JAB":
			return Vector2(0, curr_vel.y)
		"DASH":
			if ticker > 7:
				if abs(curr_vel.x) > owner.friction: 
					curr_vel.x -= owner.friction if curr_vel.x > 0 else -owner.friction
				else: 
					curr_vel.x = 0
			return curr_vel
			
	return curr_vel

func state_logic(delta): 
	# if in hitlag, decrement hitlag frames 
	if hitlag_frames: 
		hitlag_frames -= 1
		if hitlag_frames == 0: 
			owner.get_node("AnimationPlayer").play()
			owner.velocity = hitlag_velocity

	# else, incr. ticker and do hitbox stuff
	else: 
		match type: 
			
			"JAB": 
				#first hitbox
				if ticker == 2: 
					# create jab hitbox, set all the properties 
					var jab_hb = hb_scene.instance()
					jab_hb.set_pos(Vector2(70, 15))
					jab_hb.set_rect(62,32)
					jab_hb.player_id = owner.ID
					jab_hb.attack_name = "JAB"
					jab_hb.damage = 4
					jab_hb.knockback = 0
					jab_hb.base_knockback = 0
					jab_hb.kb_growth = 100
					jab_hb.priority = 0
					jab_hb.kb_angle = 70
					# add to owner scene & hb dict
					owner.get_node("position").add_child(jab_hb)
					hitboxes[0] = jab_hb
#				elif ticker == 5: 
					# the delayed part of the jab for testing
					
					
			# remove active hitbox on frame 16
			"DASH": 
				if ticker == 0: 
					var dash_hb = hb_scene.instance()
					dash_hb.set_capsule(40,172)
					dash_hb.set_shape_angle(94)
					dash_hb.set_pos(Vector2(50, -40))
					dash_hb.attack_name = "DASH"
					dash_hb.damage = 10
					dash_hb.kb_growth = 90
					dash_hb.kb_angle = 45
					dash_hb.base_knockback = 22
					dash_hb.player_id = owner.ID
					dash_hb.priority = 0
					owner.get_node("position").add_child(dash_hb)
					hitboxes[0] = dash_hb
					
				elif ticker == 16: 
					hitboxes[0].queue_free()
					hitboxes.erase(0)
					
		ticker += 1
	
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

func check_state():
	if ticker >= timer: 
#		return "IDLE"
		owner.change_state("IDLE")
	return
