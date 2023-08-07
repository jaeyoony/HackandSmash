extends "../state_template.gd"
var ticker = 0 
var BACKWARDS_ROLL = false

# RNG generator for DUMMY MODE
var rng = RandomNumberGenerator.new()

func get_name(): 
	return "ROLL"
	
func enter():
	ticker = 0
	owner.get_node("AnimationPlayer").play("ROLL")
	
	# if dummy mode, pick a random direction
	if owner.dummy_mode: 
		var rng_call = rng.randf()
		if rng_call < 0.5: 
			BACKWARDS_ROLL = false
		else: 
			BACKWARDS_ROLL = true
			owner.get_node("position/body").set_scale(Vector2(-owner.facing, 1))
				
	# for backwards roll, flip model for animation but don't flip when we get there
	# for forwards roll, don't flip model for animation but change facing after
	elif sign(owner.stick_buffer.back().x) != owner.facing: 
		BACKWARDS_ROLL = true
#		owner.get_node("position/body/Sprite").set_flip_h(true)
		owner.get_node("position/body").set_scale(Vector2(-owner.facing, 1))
	else: 
		BACKWARDS_ROLL = false	
		
# return a constant speed during roll(?)
func calculate_velocity(dir, curr_vel): 
	# if about to go off, return 0
	if ticker > 4 and ticker < 22:
		if owner.get_node("position/body/edge_detector").is_colliding():
			if BACKWARDS_ROLL: 
				return Vector2(-owner.facing*200, 0)
			return Vector2(owner.facing*200, 0)
	return Vector2.ZERO


func state_logic(delta): 
	# disable hurtboxes for rolling part
	if ticker == 4: 
		owner.get_node("position/body/hurtboxes/hb1").set_deferred("disabled", true)
		owner.get_node("position/body/hurtboxes/hb2").set_deferred("disabled", true)
		
		owner.set_particle_style("LAND")
		owner.get_node("position/dust_particles").emitting = true
		
	# reenable hurtboxes
	# flip at the end of back roll
	if ticker == 22:
		owner.get_node("position/body/hurtboxes/hb1").set_deferred("disabled", false)
		owner.get_node("position/body/hurtboxes/hb2").set_deferred("disabled", false)
		owner.get_node("position/dust_particles").emitting = false
		
		if not BACKWARDS_ROLL: 
			owner.flip_direction(-owner.facing)
		owner.get_node("position/body").set_scale(Vector2(owner.facing, 1))
	ticker += 1 
	return

# can't really do any inputs during a roll
func process_input(dir): 
	return dir
	
func exit(): 
	# flip if we're doing forward roll
	owner.get_node("position/body").set_scale(Vector2(owner.facing, 1))
		
	# set roll_type marker to default
	BACKWARDS_ROLL = false
	ticker = 0
	# reset hurtboxes, JIC
	owner.get_node("position/body/hurtboxes/hb1").set_deferred("disabled", false)
	owner.get_node("position/body/hurtboxes/hb2").set_deferred("disabled", false)

func check_state():
	if ticker >= 31:
		if Input.is_action_pressed("shield"): 
			return "BLOCK"
		return "IDLE"
	return 
