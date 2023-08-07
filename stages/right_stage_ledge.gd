extends Area2D

# indicate the direction the ledge is "facing"
#	-1 = left, meaning players would grab from the left side
#	 1 = right, meaning players grab from the right
export(int) var DIRECTION = 1

# indicate whether or not the ledge is being used right now
export(bool) var IS_GRABBED = false

const LEDGE_GRAB_POSITION = Vector2(310,30)

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
