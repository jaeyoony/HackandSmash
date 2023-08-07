extends "../state_template.gd"
var ticker = 0 

# the num. of frames the character is exposed after dropping shield 
const SHEILD_DROP_EXPOSED_FRAMES_DEFAULT = 10

# ticker for current exposed frames (frames of defender exposed without shields, right before going into idle) 
var exposed_frames = 10

# number of frames in shieldstun remaining
var SHIELD_STUN_FRAMES = 0

# direction that shield damage came from
var SHIELD_KB_DIRECTION_AND_DAMAGE = 0

# for reference to the owner's shield
var SHIELD_SHAPE 

func get_name(): 
	return "BLOCK"
	
func enter():
	ticker = 0
	# set var
	SHIELD_SHAPE = owner.get_node("position/body/shield/shield_shape")
	# play blocking animation 
	owner.get_node("AnimationPlayer").play("BLOCK")
	
	# spawn the shield hitbox 
	# activate shield HB and make visible
	owner.get_node("position/body/shield").visible = true
	owner.get_node("position/body/shield/shield_shape").disabled = false
	
func calculate_velocity(dir, curr_vel): 
	if abs(curr_vel.x): 
		var out = curr_vel
		var shield_friction = owner.FRICTION*1.2
		if abs(out.x) > shield_friction: 
			out.x += -sign(out.x)*shield_friction 
		else: 
			out.x = 0
		return out
	return curr_vel


func state_logic(delta): 
	ticker += 1
	
	# DEBUG : if dummy mode, dont do anything
#	if owner.dummy_mode: 
#		owner.get_node("position/body/shield/shield_shape").shape.radius = owner.SHIELD_HP*3.125
#		return
	
	# if in shieldstun frames, can't do anything
	if SHIELD_STUN_FRAMES: 
		SHIELD_STUN_FRAMES-=1
		if not SHIELD_STUN_FRAMES: 
			var temp_color = SHIELD_SHAPE.get_modulate()
			temp_color.g += 0.2
			SHIELD_SHAPE.set_modulate(temp_color)
			
			# clear shieldstun vars
			SHIELD_KB_DIRECTION_AND_DAMAGE = 0
			
		
	# if shield button isn't pressed, remove the shield and wait the preset
	#	 number of exposed frames for this character 
	if not Input.is_action_pressed("shield") and not owner.dummy_mode: 
		# if this is first frame off, then remove block hitbox & shield 
		if exposed_frames == SHEILD_DROP_EXPOSED_FRAMES_DEFAULT:
			owner.get_node("position/body/shield").visible=false
			owner.get_node("position/body/shield/shield_shape").disabled = true
			
		exposed_frames -= 1
		
	elif Input.is_action_just_pressed("shield") and not owner.dummy_mode: 
		exposed_frames = SHEILD_DROP_EXPOSED_FRAMES_DEFAULT
		owner.get_node("position/body/shield").visible=true
		owner.get_node("position/body/shield/shield_shape").disabled = false
	
	else: 
		# DEBUG : check for dummy mode - if dummy, no decay
		if not owner.dummy_shield_mode: 
			# set decay to sth rlly low for now, for TESTING
			owner.SHIELD_HP -= 0.24
			owner.get_node("position/body/shield/shield_shape").shape.radius = owner.SHIELD_HP*3.125
	

# check for block shifting
# check for roll/dodge/grab inputs 
func process_input(dir): 
	# shield shifting
	if Input.is_action_pressed("walk_key"): 
		var temp_point = dir * 100
		temp_point.x *= owner.facing
		owner.get_node("position/body/shield/shield_shape").position = temp_point
	
	elif Input.is_action_just_released("walk_key"):
		owner.get_node("position/body/shield/shield_shape").position = Vector2.ZERO
		
	return dir
	
	
func exit(): 
	ticker = 0
	owner.get_node("position/body/shield").visible=false
	owner.get_node("position/body/shield/shield_shape").disabled = true
	exposed_frames = SHEILD_DROP_EXPOSED_FRAMES_DEFAULT
	SHIELD_STUN_FRAMES = 0
	SHIELD_KB_DIRECTION_AND_DAMAGE = 0

# enter shield stun 
# inputs: damage_dealt - the % dmg the attack on shield dealt
#	attack_direction - the direction of the attack relative to the shielding player
#			-1 = from the left, + 1 = from the right 
func _shield_stun(damage_dealt, attack_direction): 
	# calculate num. of frames to stay in stun 
	# change shield color
	var temp_color = SHIELD_SHAPE.get_modulate() 
	temp_color.g -= 0.2
	SHIELD_SHAPE.set_modulate(temp_color)
	SHIELD_STUN_FRAMES = floor(0.8 * damage_dealt) + 3
	SHIELD_KB_DIRECTION_AND_DAMAGE = attack_direction * damage_dealt
	# apply shieldstun knockback 
	var shield_kb = min(100, abs(SHIELD_KB_DIRECTION_AND_DAMAGE) * 5) * sign(SHIELD_KB_DIRECTION_AND_DAMAGE)
	owner.velocity.x -=  shield_kb
	

func check_state():
	if exposed_frames == 0: 
		return "IDLE"
	elif not owner.is_on_floor(): 
		owner.jumps -=1
		return "FALL"
	elif Input.is_action_pressed("jump"): 
		return "JUMP_SQUAT"
	# check for roll
	elif owner.check_smash_input('x') and Input.is_action_pressed("shield") and not SHIELD_STUN_FRAMES:
		return "ROLL"
	
	return 
