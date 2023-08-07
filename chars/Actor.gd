extends KinematicBody2D
class_name Bill

const FLOOR_NORMAL: = Vector2.UP

# default speed of the characters
export var speed: = Vector2(500.0, 1000.0)
# default air/fall speed
export var air_speed: = Vector2(250.0, 800.0)

# default universal gravity 
export var gravity: = 4000.0

var velocity: = Vector2.ZERO

var MAX_JUMPS = 2
var jumps = 2

# records the last X inputs for detection 
var INPUT_BUFFER = []

# sets a flag for the next action to be taken, as well as 
# how many frames until that action 
var ACTION_BUFFER = null
var ACTION_TIMER = null

# define state machine & to_string dict
enum states{
	IDLE, WALK, CROUCH_SQUAT, CROUCH_IDLE, CROUCH_GETUP, 
	JUMP_SQUAT, JUMP_ASCEND, JUMP_IDLE, DOUBLE_JUMP, LAND, 
	DASH_START, DASH_IDLE, DASH_STOP, DASH_BACK, DASH_DANCE_TURNAROUND, 
}
var state_strs = {
	states.IDLE: 'IDLE', 
	states.WALK: 'WALK', 
	states.CROUCH_IDLE: 'CROUCH_IDLE', 
	states.CROUCH_SQUAT: 'CROUCH_SQUAT', 
	states.CROUCH_GETUP: 'CROUCH_GETUP', 
	states.JUMP_SQUAT: 'JUMP_SQUAT',
	states.JUMP_ASCEND: 'JUMP_ASCEND', 
	states.JUMP_IDLE: 'JUMP_IDLE',
	states.LAND: 'LAND', 
	states.DASH_START: 'DASH_START', 
	states.DASH_IDLE: 'DASH_IDLE', 
	states.DASH_STOP: 'DASH_STOP', 
	states.DASH_BACK: 'DASH_BACK', 
	states.DASH_DANCE_TURNAROUND: 'DASH_DANCE_TURNAROUND',
	states.DOUBLE_JUMP: 'DOUBLE_JUMP'
}
