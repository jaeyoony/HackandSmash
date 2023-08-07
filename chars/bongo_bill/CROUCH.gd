extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var ticker = 0 
var is_getup = false

func get_name(): 
	return "CROUCH"
	
func enter():
	ticker = 0
	owner.get_node("AnimationPlayer").play("CROUCH_IDLE")
	# wavedash particles...? 
	if owner.velocity.x: 
		# set particle emission direction
		owner.set_particle_style("LAND")
		owner.get_node("position/dust_particles").emitting = true
	
	
func state_logic(delta): 
	if abs(owner.velocity.x) < 120: 
		owner.get_node("position/dust_particles").emitting = false

	if is_getup:
		ticker += 1
		
		
# get the move velocity given the character's current velocity & directional input
func calculate_velocity(_dir, curr_velocity): 
	# if moving, slow to stop - has 1.5 * traction
	var out = curr_velocity
	if abs(curr_velocity.x) > owner.FRICTION*1.5: 
		out.x += (owner.FRICTION*1.5*-sign(curr_velocity.x))
	else: 
		out.x = 0
	return out
	

func process_input(dir): 
	return dir
	
	
func exit(): 
	ticker = 0
	is_getup = false
	# reset particle emitter
	owner.get_node("position/dust_particles").emitting = false
	
	
func check_state():
	if is_getup and ticker == 4:
		return "IDLE"
	elif not owner.is_on_floor(): 
		owner.jumps -=1
		return "FALL"
	elif Input.is_action_just_pressed("jump"): 
		return "JUMP_SQUAT"
#	elif not Input.is_action_pressed("crouch"):
	elif owner.stick_buffer.back().y < 0.1:
		is_getup = true
		owner.get_node("AnimationPlayer").play("CROUCH_GETUP")
	elif Input.is_action_just_pressed("attack"): 
		return "GROUND_ATTACK"
	elif Input.is_action_just_pressed("grab"): 
		return "GRAB"
	elif Input.is_action_just_pressed("special"): 
		return "SPECIAL_ATTACK"
	return
