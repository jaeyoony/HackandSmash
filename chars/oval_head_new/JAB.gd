extends "../state_template.gd"
# ticker for entering/exiting crouch squat/getups 
var ticker = 0 
var hb = null
var hbarea = null
var area = null

var hb_scene = null
var jab_hb = null

# loads the hitbox scene
func _ready()-> void: 
	hb_scene = load("res://hboxes/hitbox.tscn")
	return

func get_name(): 
	return "JAB"
	
func enter():
#	hb = owner.get_node("Hitbox/COllisionShape2D")
	owner.get_node("AnimationPlayer").play("JAB")

	# create jab hitbox, set all the properties 
	jab_hb = hb_scene.instance()
	jab_hb.set_pos(Vector2(70, 15))
	jab_hb.set_rect(62,32)
	jab_hb.player_id = owner.ID
	
	jab_hb.attack_name = "JAB"
	jab_hb.damage = 4
	jab_hb.knockback = 0
	jab_hb.base_knockback = 0
	jab_hb.kb_growth = 100
	jab_hb.angle = 70
	# add to owner scene
	owner.get_node("body").add_child(jab_hb)
	
func process_input(dir):
	# can't move and jab simultaneously
	dir.x = 0
	return dir

func state_logic(delta): 
	# make hitbox move forward
	ticker += 1
	
func exit(): 
	jab_hb.queue_free()
	ticker = 0

func check_state():
	if ticker == 10: 
#		return "IDLE"
		owner.change_state("IDLE")
	return
