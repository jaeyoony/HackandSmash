extends Node2D

var num_players = 2

# load in assets
const punch_bag = preload("res://chars/punching_bag/punching_bag.tscn")
const bongo_bill = preload("res://chars/bongo_bill/bongo_bill.tscn")
const expl = preload("res://assets/effects/explosion/explosion.tscn")

# load in UI assets
const CHAR_UI = preload("res://ui/player_ui.tscn")

# RNG
var RNG = RandomNumberGenerator.new()

var oldx = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return
#
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
##	if $players/ovalHead.position.x != oldx: 
##		oldx = $players/ovalHead.position.x
##		print(oldx)v
#
#	# print controller left stick input to see if its all whack
##	print(Vector2(Input.get_joy_axis(0,JOY_ANALOG_LX),  Input.get_joy_axis(0,JOY_ANALOG_LY)),
##		Vector2(Input.get_joy_axis(0,JOY_ANALOG_RX),  Input.get_joy_axis(0,JOY_ANALOG_RY)))
##	print(Input.get_joy_name(0))
#	# check if 
#
#	# DEBUG : check for debug button press
#	if Input.is_action_just_pressed("debug_button"): 
#		print("Debug btn pressed")
#		# put all chars not player char into shield dummy state
#		for i in PLAYER_IDS.keys(): 
#			if i: 
#				PLAYER_IDS[i].dummy_shield_mode = !PLAYER_IDS[i].dummy_shield_mode
#				PLAYER_IDS[i].change_state("IDLE")
#
#
#	# spawn new bongo bill on 'test_reset' button press
#	if Input.is_action_just_pressed("test_reset"):
#		print("Test reset button pressed...")
#		# add a new dummy... and set his color to something weird lmao
#		var new_dummy = bongo_bill.instance()
#		var index = $players.get_children().size()
#		new_dummy.ID = index
#		new_dummy.dummy_mode = true
#
#		new_dummy.position = $spawn_point_2.position
#
#		# give him some random color, to be cute
#		RNG.randomize()
#		new_dummy.get_node("position/body/Sprite").self_modulate = Color(RNG.randf_range(0.3,0.9),
#			RNG.randf_range(0.3,0.9),
#			RNG.randf_range(0.3,0.9)
#		)
#
#		# set random size bc haha funny
#		var temp_scale = RNG.randf_range(0.06, 0.12)
#		new_dummy.set_scale(Vector2(temp_scale, temp_scale))
#
#		# give random percentage to not make it so every character reacts the same to hits
#		new_dummy.PERCENT = RNG.randi_range(0, 30)
#
#		new_dummy.position.y = $spawn_point_1.position.y
#		new_dummy.position.x = RNG.randi_range($spawn_point_1.position.x, $spawn_point_2.position.x)
#
#		# add to game 
#		print("New dummy index : ", index)
#		$players.add_child(new_dummy)
#		PLAYER_IDS[index] = new_dummy
#		$players/stage_cam.add_target(new_dummy)
#
#	return

# Handle player death 
func _on_blastzone_area_entered(area: Area2D) -> void:
	var temp = area.owner

	# activate player death in the gameloop 
	get_parent().get_owner().player_death(temp.ID)
#
#	return

