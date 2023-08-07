extends Control

# the character instance that this UI element is watching 
var TARGET

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_target(char_instance): 
	TARGET = char_instance
	get_node("Playername").text = TARGET.name
	
# clears the character instance, refreshing the percentage
func clear_target(): 
	TARGET = null
	get_node("Percent").text = ""
	

func set_rectangle_color(color_in): 
	$rectangle.color = color_in


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if TARGET: 
		get_node("Percent").text = str(TARGET.PERCENT)
