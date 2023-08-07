extends KinematicBody2D
const FLOOR_NORMAL: = Vector2.UP

# how many frames the projectile has been "alive" 
var TICKER = 0

# id of the player who owns this projectile
var PLAYER_ID = -1

const IS_PROJECTILE = true
const IS_GRAB = false

# indicates the direction the projectile is traveling
#	-1 : going to the left
#	+1 : going to the right
var DIRECTION = -1
const PROJECTILE_SPEED = 20

const damage = 1
const knockback = 1
const priority = 0
var base_knockback = 0
var set_knockback = 0
var base_hitstun = 0
var kb_growth = 0
var kb_angle = 0

const attack_name = 'bongo_bill_neutral_special'

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return

# sets the direction of the projectile
func init(owner_id, direction, starting_position): 
	PLAYER_ID = owner_id
	DIRECTION = direction
	position.x = starting_position.x + (DIRECTION*20)
	position.y = starting_position.y - 6
	return

# call to destroy itself 
func destroy(): 
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	move_and_collide(Vector2(PROJECTILE_SPEED*DIRECTION, 0))
	TICKER += 1
	
	# check for expiration
	if TICKER > 80: 
		queue_free() 


# destroy bullet upon it hitting the wall/stage
func _on_Area2D_body_entered(body: Node) -> void:
	destroy()
