extends Camera2D


export var move_speed = 0.5
export var zoom_speed = 0.05
export var min_zoom = 0.25
export var max_zoom = 1

# variables for set zoom
export var preset_zoom = 0
var ticker = 0

# area around the edge of camera to the targets of the camera
export var margin = Vector2(110, 140) 

var targets = []

onready var screen_size = get_viewport_rect().size

# allows us to add/remove targets from the camera
func add_target(targ):
	if not targ in targets: 
		targets.append(targ)

func remove_target(targ): 
	if targ in targets: 
		targets.erase(targ)

func preset_zoom(zoomlvl): 
	preset_zoom = zoomlvl

func remove_set_zoom(): 
	preset_zoom = 0
	
func set_zoom_speed(speed): 
	zoom_speed = speed

func reset_zoom_speed(): 
	zoom_speed = 0.5
	


func _process(delta):
	# nothing on screen, so no need to move camera
	if !targets: 
		return
	
	# else, average positions of all entities we're tracking
	var temp_pos = Vector2.ZERO
	for t in targets: 
		# check if t is a vector or character w/ position coord
		temp_pos += t.position
	temp_pos /= targets.size()
	# slowly move the cam to the new position
	position = lerp(position, temp_pos, move_speed)
	
	# if there's a set zoom lvl, 
	if preset_zoom != 0: 
		zoom = lerp(zoom, Vector2.ONE*preset_zoom, zoom_speed)
	
	else: 
		# now, find zoom level
		# init. rectangle has position at cam's current pos w/ sides of length 1
		var r = Rect2(position, Vector2.ONE)
		# reshape our temp rectangle to include all targets & the camera margin
		for t in targets: 
			r = r.expand(t.position)
		r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
		var d = max(r.size.x, r.size.y)
		var zoomlvl
		if r.size.x > r.size.y * screen_size.aspect(): 
			zoomlvl = clamp(r.size.x/screen_size.x, min_zoom, max_zoom)
		else: 
			zoomlvl = clamp(r.size.y/screen_size.y, min_zoom, max_zoom)
		zoom = lerp(zoom, Vector2.ONE*zoomlvl, zoom_speed)
	
	
