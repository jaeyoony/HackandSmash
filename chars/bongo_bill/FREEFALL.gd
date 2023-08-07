extends "../state_template.gd"
const PLATFORM_BIT = 4

const landing_lag = 25

func get_name(): 
	return "FALL"


func enter(): 
	owner.get_node("AnimationPlayer").play("FALL")
	# darken color 
	owner.get_node("position/body/Sprite").modulate = Color(0.5,0.5,0.5)

	
func process_input(dir): 
	return dir

func state_logic(delta): 
	# check for fastfalling/falling thru platforms input 
	if !owner.fastfalling and !owner.is_on_floor() and Input.is_action_just_pressed("crouch"+owner.INPUT_KEY) and owner.velocity.y >=-10: 
		owner.fastfalling = true
		owner.set_collision_mask_bit(PLATFORM_BIT, false)
	
	
func check_state(): 
	if owner.is_on_floor(): 
		return "LAND"

func exit(): 
	owner.get_node("position/body/Sprite").set_modulate(Color(1,1,1))

