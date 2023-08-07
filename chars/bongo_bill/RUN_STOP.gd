extends "../state_template.gd"
var TICKER = 0

func get_name(): 
	return("RUN_STOP")

func enter():
	owner.get_node("AnimationPlayer").play("RUN_STOP")
	owner.set_particle_style("RUN")
	
	# set special particle emission direction
	owner.get_node("position/dust_particles").set_scale(Vector2(owner.facing, 1))
	owner.get_node("position/dust_particles").set_position(Vector2(owner.facing*150, 280))
	# set particle emission to on 
	owner.get_node("position/dust_particles").emitting = true
	
#func process_input(dir): 
#	dir.x = 0
#	return dir

func state_logic(delta): 
	TICKER += 1
	if TICKER == 12: 
		owner.get_node("position/dust_particles").set_position(Vector2(0, 280))
		owner.get_node("position/dust_particles").emitting = false
		
	

func exit(): 
	owner.get_node("position/dust_particles").emitting = false
	TICKER = 0
	

func check_state(): 
	if !owner.is_on_floor(): 
		owner.jumps -= 1
		return "FALL"
	# 15 frames long
	if(TICKER == 16):
		# check if run is held in the opposite direction
		if owner.facing != sign(owner.stick_buffer.back().x) and abs(owner.stick_buffer.back().x) >= owner.dash_thr:
			# turn around and go
#			owner.facing = sign(owner.stick_buffer.back().x)
#			owner.get_node("position/body").set_scale(Vector2(owner.facing,1))
			owner.flip_direction(sign(owner.stick_buffer.back().x))
			return "RUN"
		return "IDLE"
		
	# check for RAR 
	elif owner.facing != sign(owner.stick_buffer.back().x) and Input.is_action_just_pressed("jump"): 
		owner.flip_direction(-owner.facing)
		return "JUMP_SQUAT"
	return


