extends Node2D

var num_players = 2

# load in assets
const punching_bag = preload("res://chars/punching_bag/punching_bag.tscn")
const bongo_bill = preload("res://chars/bongo_bill/bongo_bill.tscn")
const expl = preload("res://assets/effects/explosion/explosion.tscn")

# load in UI assets
const CHAR_UI = preload("res://ui/player_ui.tscn")

# load in resources 
const CHARACTER_OBJ_RESOURCE = preload("res://resources/char_obj.gd")
const CHARACTER_TIMER_RESOURCE = preload("res://resources/player_timers.gd")

# RNG
var RNG = RandomNumberGenerator.new()

var oldx = null

var ACTIVE_DEVICES = {}

# dict to keep track of character id's : character_obj (resource)
var PLAYERS = {}

# keeps track of character names w/ ID value 
var PLAYER_IDS = {}

# ui dict for quick access to a player's individual UI element
var PLAYER_UI_DICT = {}

# dict to keep track of which device corresponds to which player ID
#	key = index in device list : val = player_ID corresponding to that device 
var PLAYER_DEVICE_DICT = {}

# keeps track of references to each players respective Timer responsible for
#	triggering their respawning. 
# note that the actual timers are added as children to this scene, and these 
#	just contain "references" to them (in quotes b/c im not actually sure how 
#	godot handles stored variables/references lol) 
var RESPAWN_TIMERS = {}

# saves timers for each specific input device/player in game
var TIMERS = {}

var STAGE_INSTANCE = null

# TESTING VARS to test multiple inputs
const MULTIPLAYER_MODE = false # if TRUE, make a p1 and a p2 bongo bill independently controlled 
const KEYBOARD_MODE = true 
# flag to indicate whether to count keyboard as a valid input soruce (aka make keyboard p1/p2)
# if true, will spawn an extra character beyond controllers connected 
#	that is in dummy mode
const DUMMY_MODE = true 


# called to load the stage scene 
func _load_stage(stage_path="res://stages/template.tscn"):  
	var temp_stage_inst = load(stage_path).instance()
	return temp_stage_inst


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# DEBUG: slomo for testing 
#	Engine.time_scale = 0.25

	# get list of active devices, removing those that aren't playing... hard code for now
	var ACTIVE_DEVICES = Input.get_connected_joypads()
	# if keyboard mode is on, add keyboard to active devices 
	if KEYBOARD_MODE: 
		ACTIVE_DEVICES.push_back("K")
	if DUMMY_MODE: 
		ACTIVE_DEVICES.push_back("D")


	# instance stage and add
	var temp_stage = _load_stage()
	$stage.add_child(temp_stage)

	# Creating instance per active device
	var id_count = 0
	for i in ACTIVE_DEVICES: 
		
#		print(i)
#		print(Input.get_joy_name(i))
		
		if typeof(i) == TYPE_INT and Input.get_joy_name(i) == 'XInput Gamepad': 
			continue
		
		var temp_id = id_count
		
		# create char obj & add to dict 
		var temp_obj = CHARACTER_OBJ_RESOURCE.new()
#		char_obj_0.init(0, '_keyboard', ui1, temp1, "res://chars/bongo_bill/bongo_bill.tscn")
		var temp_input_key
		
		# normally, load the characters you chose here
		#	for now, hard code it to always be bongo bill 
		var temp_inst = bongo_bill.instance()
		
		if str(i) == 'K': 
			temp_input_key = '_keyboard'
		elif str(i) == 'D': # dummy mode, tie inputs to first device i guess..? 
			temp_input_key = '_p1'
#			temp_inst = punching_bag.instance()
			temp_inst.dummy_mode = true
			
		else: 
			temp_input_key = '_p' + str(temp_id+1)
		
		# create UI per player
		var ui1 = CHAR_UI.instance()
		ui1.set_target(temp_inst)
		$UI_elements/HBoxContainer.add_child(ui1)
		PLAYER_UI_DICT[temp_id] = ui1
		
		# Do setup for character_object 

		temp_obj.init(temp_id, temp_input_key, ui1, temp_inst)
		temp_obj.setup_instance()
		
		# create respawn timers & save
		var temp_timer = Timer.new()
		temp_timer.set_one_shot(true)
		temp_timer.set_wait_time(2.5)
		RESPAWN_TIMERS[temp_id] = temp_timer
		add_child(temp_timer)
		
		# add as child of gameloop
		$players.add_child(temp_inst)
		
		# set starting pos
		var temp_node = 'spawn_point_' + str((temp_id%2)+1)
		temp_inst.position = $stage.get_child(0).get_node(temp_node).position
		
		# add to stage cam tracking
		$players/stage_cam.add_target(temp_inst)
		
		# loop stuff, meta stuff		
		id_count += 1 
		PLAYER_DEVICE_DICT[temp_id] = i
		PLAYERS[temp_id] = temp_obj

#	# instance & create node
#	# create player_id dictionary that assigns id value to node 
#	var temp1 = bongo_bill.instance()
#	var temp2 = bongo_bill.instance()
#
#	# ASSIGN EACH CHARACTER INSTANCE THIER PLAYER_ID (i.e. what player is controlling them, their unique ID for the match) 
#	# hardcode these values for now
#	temp1.ID = 0
#	temp2.ID = 1
#	temp1.set_scale(temp1.CHAR_SPRITE_SCALE)
#	temp2.set_scale(temp2.CHAR_SPRITE_SCALE)
#
##	# DEBUG - set p2 dummy vars
##	temp2.dummy_mode = true
##	temp2.dummy_shield_mode = false
#
#	# add to our dict to keep track
#	PLAYER_IDS[0] = temp1
#	PLAYER_IDS[1] = temp2
#
#	# DEBUG : eventually dynamically assign controllers to ID's	
##	# assign each player their INPUT_TAG depending on device
##		the "get_connected_joypads()" method returns a list of id's for the devices connected!
#
##	for i in Input.get_connected_joypads(): 
##		print(Input.get_joy_name(i))
##
##		# IGNORE THE "XINPUT GAMEPAD"
##
##		# if KEYBOARD_MODE is true, assign 
#
#	# hard code for now..? 
#	if KEYBOARD_MODE: 
#		PLAYER_IDS[0].INPUT_KEY = '_keyboard'
#		PLAYER_IDS[1].INPUT_KEY = '_p1'
#		PLAYER_DEVICE_DICT[0] = '_keyboard'
#		PLAYER_DEVICE_DICT[1] = '_p1'
#
#	else: 
#		PLAYER_IDS[0].INPUT_KEY = '_p1'
#		PLAYER_IDS[1].INPUT_KEY = '_p2'
#		PLAYER_DEVICE_DICT[0] = '_p1'
#		PLAYER_DEVICE_DICT[1] = '_p2'
#
#	# create respawn timers & store 
#	RESPAWN_TIMERS[0] = Timer.new()
#	RESPAWN_TIMERS[1] = Timer.new()
#	for t in RESPAWN_TIMERS: 
#		RESPAWN_TIMERS[t].set_one_shot(true)
#		RESPAWN_TIMERS[t].set_wait_time(2.5)
#		add_child(RESPAWN_TIMERS[t])
#
#	# add to our stage 
#	$players.add_child(temp1)
#	$players.add_child(temp2)
#
#	# set starting pos
#	temp1.position = $stage.get_child(0).get_node('spawn_point_1').position
#	temp2.position = $stage.get_child(0).get_node('spawn_point_2').position
#
#	# add players to stage_cam tracking
#	$players/stage_cam.add_target(temp1)
#	$players/stage_cam.add_target(temp2)
#
#	# add UI per each character
#	var ui1 = CHAR_UI.instance()
#	var window_height = ProjectSettings.get('display/window/size/height')
#	ui1.set_target(temp1)
#	$UI_elements/HBoxContainer.add_child(ui1)
#	PLAYER_UI_DICT[0] = ui1
##	ui1.set_position(Vector2(100, window_height-250))
#
#	var ui2 = CHAR_UI.instance()
#	ui2.set_target(temp2)
#	ui2.set_rectangle_color(Color(0.1, 0.1, 0.8, 0.3))
#	$UI_elements/HBoxContainer.add_child(ui2)
#	PLAYER_UI_DICT[1] = ui2
##	ui2.set_position(Vector2(400, window_height-250))
#
#	# create char_obj instances 
#	var char_obj_0 = CHARACTER_OBJ_RESOURCE.new()
#	char_obj_0.init(0, '_keyboard', ui1, temp1, "res://chars/bongo_bill/bongo_bill.tscn")
#	var char_obj_1 = CHARACTER_OBJ_RESOURCE.new()
#	char_obj_1.init(1, '_p1', ui2, temp2, "res://chars/bongo_bill/bongo_bill.tscn")
#	# assign to PLAYERS dict. 
#	PLAYERS[0] = char_obj_0
#	PLAYERS[1] = char_obj_1
#
	
#	# set camera limits, specific to each stage!
	$players/stage_cam.limit_left = -500
	$players/stage_cam.limit_right = 500
	$players/stage_cam.limit_top = -360
	$players/stage_cam.limit_bottom = 280


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	if $players/ovalHead.position.x != oldx: 
#		oldx = $players/ovalHead.position.x
#		print(oldx)v

	# print controller left stick input to see if its all whack
#	print(Vector2(Input.get_joy_axis(0,JOY_ANALOG_LX),  Input.get_joy_axis(0,JOY_ANALOG_LY)),
#		Vector2(Input.get_joy_axis(0,JOY_ANALOG_RX),  Input.get_joy_axis(0,JOY_ANALOG_RY)))
#	print(Input.get_joy_name(0))
	# check if 
	
#	# NOTE : for y input, -1 == UP and 1 == DOWN
#	var INPUT_KEY = '_p2'
#	var out = Vector2(
#		Input.get_action_strength("move_right"+INPUT_KEY) - Input.get_action_strength("move_left"+INPUT_KEY),
#		-Input.get_action_strength("stick_up"+INPUT_KEY) + Input.get_action_strength("crouch"+INPUT_KEY)
#	)
#	print("PRINT TEST OUTPUT : ", out)


	# DEBUG : check for debug button press
	if Input.is_action_just_pressed("debug_button"): 
		print("Debug btn pressed")
		# put all chars not player char into shield dummy state
		for i in PLAYER_IDS.keys(): 
			if i: 
				PLAYER_IDS[i].dummy_shield_mode = !PLAYER_IDS[i].dummy_shield_mode
				PLAYER_IDS[i].change_state("IDLE")
	
	# spawn new bongo bill on 'test_reset' button press
	if Input.is_action_just_pressed("test_reset"):
		print("Test reset button pressed...")
		
		var spawn_pt_1 = $stage.get_child(0).get_node('spawn_point_1').position
		var spawn_pt_2 = $stage.get_child(0).get_node('spawn_point_2').position
		
		# add a new dummy... and set his color to something weird lmao
		var new_dummy = bongo_bill.instance()
		var index = $players.get_children().size()
		new_dummy.ID = index
		new_dummy.dummy_mode = true
		
		new_dummy.position = $stage.get_child(0).get_node('spawn_point_2').position
		
		# give him some random color, to be cute
		RNG.randomize()
		new_dummy.get_node("position/body/Sprite").self_modulate = Color(RNG.randf_range(0.3,0.9),
			RNG.randf_range(0.3,0.9),
			RNG.randf_range(0.3,0.9)
		)
		
		# set random size bc haha funny
		var temp_scale = RNG.randf_range(0.06, 0.12)
		new_dummy.set_scale(Vector2(temp_scale, temp_scale))
		
		# give random percentage to not make it so every character reacts the same to hits
		new_dummy.PERCENT = RNG.randi_range(0, 30)
		
		new_dummy.position.y = spawn_pt_1.y
		new_dummy.position.x = RNG.randi_range(spawn_pt_1.x, spawn_pt_2.x)
		
		# add to game 
		print("New dummy index : ", index)
		$players.add_child(new_dummy)
		PLAYER_IDS[index] = new_dummy
		$players/stage_cam.add_target(new_dummy)
	
	return


# respawns a the character in the given spawn point
func _respawn(char_id): 
	# stop the timer
	RESPAWN_TIMERS[char_id].stop()
	var char_obj = PLAYERS[char_id]
	# create instance & add 
	var bill_inst = bongo_bill.instance()
	# make sure that there is no current instance
	assert(char_obj.CHARACTER_INSTANCE == null)
	char_obj.CHARACTER_INSTANCE = bill_inst
	char_obj.setup_instance()
	
	# set position and initial scale
	bill_inst.position = $stage.get_child(0).get_node('spawn_point_1').position
	
	# add instance to player_ui
	PLAYERS[char_id].CHARACTER_UI.set_target(bill_inst)

	# add to camera 
	$players/stage_cam.add_target(bill_inst)

	# add to tree
	$players.add_child(bill_inst)
	
	# remove preset zoom on playercam
	$players/stage_cam.remove_set_zoom()


# Handle player death 
func player_death(dead_player_id) -> void: 
	# set preset zoom so you can see the explosion a little lol
	$players/stage_cam.preset_zoom(0.4)
	
	var temp_inst = PLAYERS[dead_player_id].CHARACTER_INSTANCE
	
	# adjust stock counts
	PLAYERS[dead_player_id].STOCKS -= 1 
	if PLAYERS[dead_player_id].STOCKS > 0: 
		PLAYERS[dead_player_id].CHARACTER_UI.get_node('stock_container').get_children().back().queue_free()
	
	# end the game if stock count reaches 0 for a player 
	else: 
		get_tree().quit()
	
	# spawn explosion at that location, bc haha funny!
	var death_expl = expl.instance()
	add_child(death_expl)
	death_expl.position = Vector2(temp_inst.position.x, temp_inst.position.y-20) 
	death_expl.play("explode")
	
	# activate respawn timers
	RESPAWN_TIMERS[dead_player_id].connect("timeout",self,"_respawn",[dead_player_id])
	RESPAWN_TIMERS[dead_player_id].start()
	
	# remove camera tracking
	$players/stage_cam.remove_target(temp_inst)
	# delete that char instance 
	temp_inst.queue_free()
#	PLAYER_IDS.erase(dead_player_id)
	# create temp respawn timer 
	
	# clear character ui
	PLAYERS[dead_player_id].CHARACTER_UI.clear_target()
	
	return

