extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var TICKER = 0 
# timer to indicate when to exit attack state
var timer = 0
# bool to indicate if airdodge was buffered from jumpsquat or not
var BUFFERED = false

var PLATFORM_BIT = 4


func get_name(): 
	return "AIRDODGE"
	
	
func enter():
	owner.AIRDODGE_AVAILABLE = false
	# enable platform collision
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	owner.get_node("AnimationPlayer").play("AIRDODGE")
	owner.fastfalling = false
	
	# check if airdodge was buffered or not
	if owner.prev_state == 'JUMP_SQUAT': 
		BUFFERED = true
	elif owner.prev_state == 'FP_JUMP': 
		# activate hitspark thing
		owner.get_node("position/body/hitspark_generator").activate()
		
		# activate the SHADERS
		BUFFERED = false
		
	else: 
		BUFFERED = false
	
	
func process_input(dir):
	return dir


# calculate the move velocity during moves:
func calculate_velocity(dir, curr_vel):
	if TICKER == 1: 		
		if dir == Vector2.ZERO: 
			return Vector2.ZERO
		else: 
			# If buffered, then reduce speed of airdodge
			if BUFFERED: 
				return dir.normalized()*owner.AIRDODGE_SPEED*0.85
			# return a unit vector of the input 
			return dir.normalized()*owner.AIRDODGE_SPEED
			
			
	return curr_vel * 0.9


func state_logic(delta):
	if TICKER == 2: 
		owner.get_node("position/dust_particles").emitting = false
	# disable hurtbox, modulate
	if TICKER == 4: 
		# disable hurtbox on entry
		owner.get_node("position/body/hurtboxes/hb1").set_deferred("disabled", true)
		owner.get_node("position/body/hurtboxes/hb2").set_deferred("disabled", true)
		owner.get_node("position/body/Sprite").modulate = Color(0,0.99,0)
		owner.get_node("position/body/hurtboxes/hb1").disabled = true
		
	if TICKER == 29: 
		owner.get_node("position/body/hurtboxes/hb1").set_deferred("disabled", false)
		owner.get_node("position/body/hurtboxes/hb2").set_deferred("disabled", false)
		owner.get_node("position/body/Sprite").modulate = Color(1,1,1)
		owner.get_node("position/body/hurtboxes/hb2").disabled = false
		
	TICKER += 1
	return


func exit(): 
	# reset modulation color
	owner.get_node("position/body/Sprite").set_modulate(Color(1,1,1))
	# reset body position to 0, shifted downwards to match jumping anim. 
	owner.get_node("position/body").set_position(Vector2.ZERO)
	# set hurtboxes to active 
	owner.get_node("position/body/hurtboxes/hb1").disabled = false
	owner.get_node("position/body/hurtboxes/hb2").disabled = false
	TICKER = 0


func check_state():
	if owner.is_on_floor(): 
		return "LAND"
	elif TICKER == 49: 
		return "FALL"
