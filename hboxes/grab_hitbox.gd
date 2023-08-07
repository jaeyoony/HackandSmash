extends Node2D

# grabs are not projectiles!
const IS_PROJECTILE = false
const IS_GRAB = true

# NOTE: the big difference between projectiles and this hitbox class is that projectiles 
#	lack the ability to log 'has_hit' for their owners, or at least it seems unecessary
#	and complex to implement. instead, since projectiles should be erased after one hit in most cases, 
#	just delete the projectile as it enters the body

# class that handles the creation of temporary collisionshapes 
# for character moves. Used to create hitboxes for attacks 
var ticker = 0

var knockback = null
var base_knockback = 0
var set_knockback = 0
var kb_growth = null
var kb_angle = 0

# the id of the hitbox for a given move: used for priority for multi-hitbox moves 
# default to 0 for base priority, 1 = higher priority, etc. 
#	grabs, by default, have high priority
var priority = 5
# the id of the character who performed the move
var PLAYER_ID = null 
# the type of attack performed, i.e. BAIR 
var attack_name = null
# the damage dealt by the move 
var damage = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

func set_pos(pos_vec): 
	$hitbox/CollisionShape2D.set_position(pos_vec)
	
func set_shape(shape): 
	$hitbox/CollisionShape2D.set_shape(shape)
	
# sets the color of the hitbox when it is set to visible
# default is red 
func set_color(color): 
	$hitbox/CollisionShape2D.set_modulate(color)

# creates & sets the collision shape to a rectangle w/ given width, height
func set_rect(width, height): 
	var new_shape = RectangleShape2D.new()
	new_shape.set_extents(Vector2(width, height))
	set_shape(new_shape)
	
# creates & sets the collision shape to a circle w/ given radius
func set_circle(radius):
	var new_shape = CircleShape2D.new()
	new_shape.set_radius(radius)
	set_shape(new_shape)

func set_capsule(radius, height):
	var new_shape = CapsuleShape2D.new()
	new_shape.set_height(height)
	new_shape.set_radius(radius)
	set_shape(new_shape)

func set_shape_angle(deg):
	$hitbox/CollisionShape2D.set_rotation_degrees(deg)
	
func set_knockback(kb): 
	knockback = kb
	
func set_player(pid): 
	PLAYER_ID = pid


#func _on_hitbox_area_entered(area: Area2D) -> void:
#	if area.name == "hurtbox" and area.owner.ID != player_id and !get_parent().owner.has_hit.has(area.owner.ID):
#		print("This should print once... please")
#		# freeze 
#		pass
