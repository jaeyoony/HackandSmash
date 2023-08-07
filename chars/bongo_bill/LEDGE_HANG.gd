extends "../state_template.gd"

# ticker for keeping track of elapsed frames
var TICKER = 0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func get_name(): 
	return "LEDGE_HANG"
	
# TODO: how to pass in a hitbox as parameter here? 
# TODO: set 'body' node's position here so it doesn't look super dumb...
#	i.e. where it is WRT the actual ledge on stage
func enter(): 
	# reset the owner's jumps
	owner.jumps = owner.MAX_JUMPS
	# reset owner's airdodge
	owner.AIRDODGE_AVAILABLE = true
	# flip direction 
	owner.get_node("AnimationPlayer").play("LEDGE_HANG")

func exit(): 
	# reset ticker 
	TICKER = 0
	
func process_input(dir): 
	return dir

# on ledge, not moving so return zero vector
func calculate_velocity(dir, curr_velocity): 
	return Vector2.ZERO
	

func state_logic(delta): 
	TICKER += 1 
	return 
	
	
func check_state(): 
	# ledge jump
	if Input.is_action_just_pressed("jump"):
		print("should go into ledge jump (tourney winner), not just double jump")
		owner.jumps -= 1
		return "DOUBLE_JUMP"
	
	# fastfall ledgedrop
	elif Input.is_action_just_pressed("crouch") and owner.stick_buffer.back().y > 0.5:
		owner.fastfalling = true
		return "FALL" 
	# slowfall ledgedrop
	elif abs(owner.stick_buffer.back().x) > 0.5 and sign(owner.stick_buffer.back().x) != sign(owner.facing): 
		return "FALL"
		
	# ledge attack 
	elif Input.is_action_just_pressed("attack"): 
		print("should go into ledge getup attack")
		
	# ledge roll
	elif Input.is_action_just_pressed("shield"): 
		print("should go into ledge roll")

