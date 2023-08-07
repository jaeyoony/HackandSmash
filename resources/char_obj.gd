class_name char_object extends Resource


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var CHAR_INPUT_KEY # the INPUT_KEY for this character
var PLAYER_ID
var CHARACTER_UI 
var CHARACTER_INSTANCE

var CHAR_SCENE_PATH = ""

export(int) var STOCKS = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func init(player_id, input_key, char_ui, char_inst, path_to_char_scene=""): 
	CHAR_INPUT_KEY = input_key
	PLAYER_ID = player_id
	CHARACTER_UI = char_ui
	CHARACTER_INSTANCE = char_inst
	CHAR_SCENE_PATH = path_to_char_scene
	
func set_char_path(path): 
	CHAR_SCENE_PATH = path
	
func setup_instance(): 
	CHARACTER_INSTANCE.ID = PLAYER_ID
	CHARACTER_INSTANCE.INPUT_KEY = CHAR_INPUT_KEY
	CHARACTER_INSTANCE.set_scale(CHARACTER_INSTANCE.CHAR_SPRITE_SCALE)
	
	
