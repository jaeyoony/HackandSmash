extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var DEATH_TIMER 
var RESPAWN_TIMER 

# ID of the 
var ID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DEATH_TIMER = Timer.new()
	RESPAWN_TIMER = Timer.new()
	RESPAWN_TIMER.set_one_shot(true)
	DEATH_TIMER.set_one_shot(true)
	pass # Replace with function body.
	
	
func set_id(player_id): 
	ID = player_id
	return
	

func set_death_timer(frames): 
	pass
	
func handle_death(): 
	pass
	
func set_respawn_timer(frames): 
	pass
	
func handle_respawn(): 
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
