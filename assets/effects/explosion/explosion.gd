extends AnimatedSprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	print(is_playing())
#	if not playing: 
#		print("Finished explosion")
#		queue_free()
#	else: 
#		print("Stil exploding")


func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
