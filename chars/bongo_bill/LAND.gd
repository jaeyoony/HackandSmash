extends "../state_template.gd"
var ticker = 0
var DEFAULT_LANDING = 4
var landing_frames = 4
const PLATFORM_BIT = 4

func get_name(): 
	return "LAND"
	
func enter(): 
	# set particle emission 
	owner.set_particle_style("LAND")
	owner.get_node("position/dust_particles").emitting = true
	
	# set collision w/ platforms on again 
	owner.set_collision_mask_bit(PLATFORM_BIT, true)
	
	owner.jumps = owner.MAX_JUMPS
	owner.AIRDODGE_AVAILABLE = true
	owner.get_node("AnimationPlayer").play("LAND")
	 # reset fastfall variable
	owner.fastfalling = false

func calculate_velocity(dir, curr_velocity): 
	# else, use FRICTION to slow down to stop 
	var out = curr_velocity
	if abs(out.x): 
		if abs(out.x) > owner.FRICTION: 
			out.x -= owner.FRICTION if out.x > 0 else -owner.FRICTION
		else: 
			out.x = 0
	return out 

func state_logic(delta): 
	ticker += 1
	if ticker == 2: 
		owner.get_node("AnimationPlayer").stop(false)
	if landing_frames - ticker == 2: 
		owner.get_node("AnimationPlayer").play()
	
	# disable particles after 5 frames, because it looks dumb with long landing lag
	if ticker == 5: 
		owner.get_node("position/dust_particles").emitting = false

func exit(): 
	ticker = 0
	# set base landing frames of 4 
	landing_frames = DEFAULT_LANDING
	
	# reset particles
	owner.get_node("position/dust_particles").emitting = false
	
func check_state(): 
	if ticker == landing_frames: 
		return "IDLE"
		
	if owner.stick_buffer.back().y > 0.5:
		return "CROUCH"
	
	
