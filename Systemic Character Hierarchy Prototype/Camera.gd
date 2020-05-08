extends Camera

# Object Targeting
signal target_found
signal target_lost

export (NodePath) var hud
export (bool) var use_left_shoulder
export (float) var upper_view_limit = 15
export (float) var lower_view_limit = 3

# Target Actors
var target_actor = null
var cam_pivot
var cam_aim_pivot
var cam_aim_target
var cam_point_low
var cam_point_high
var cam_left_offset
var cam_right_offset
var target_ray
onready var cam_ray = get_node("RayCast")

# Assigned Variables
var target_object = null
var target_height
var target_ray_triggered = false
var zoom_mode_active = false

# Sensitivities and Settings
var mouse_sensitivity = 0.1
var zoom_sensitivity = 2
var zoom_level = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Interpret Zoom and Camera Rotation inputs.
func _input(event):
	if event.is_action_pressed("select"):
		var select = InputEventAction.new()
		select.action = "ui_accept"
		select.pressed = true
		Input.parse_input_event(select)
	elif event.is_action_released("select"):
		var select = InputEventAction.new()
		select.action = "ui_accept"
		select.pressed = false
		Input.parse_input_event(select)
	elif event.is_action_pressed("zoom_mode"):
		zoom_mode_active = true
	elif event.is_action_released("zoom_mode"):
		zoom_mode_active = false
	elif event.is_action_pressed("scroll_down"):
		if zoom_mode_active:
			zoom_level += zoom_sensitivity * get_process_delta_time()
			zoom_level = clamp(zoom_level, 0, 1)
		else:
			var next = InputEventAction.new()
			next.action = "ui_focus_next"
			next.pressed = true
			Input.parse_input_event(next)
			next.pressed = false
			Input.parse_input_event(next)
	elif event.is_action_pressed("scroll_up"):
		if zoom_mode_active:
			zoom_level -= zoom_sensitivity * get_process_delta_time()
			zoom_level = clamp(zoom_level, 0, 1)
		else:
			var prev = InputEventAction.new()
			prev.action = "ui_focus_prev"
			prev.pressed = true
			Input.parse_input_event(prev)
			prev.pressed = false
			Input.parse_input_event(prev)
	elif event is InputEventMouseMotion:
		cam_pivot.rotate_y(deg2rad(event.relative.x * mouse_sensitivity * -1))
		
		cam_aim_target.translate(Vector3(0, event.relative.y * 0.1 * mouse_sensitivity * -1, 0))
		var low_target_height = target_height-lower_view_limit
		var high_target_height = target_height+upper_view_limit
		cam_aim_target.translation.y = clamp(cam_aim_target.translation.y, low_target_height, high_target_height)
		
		target_ray.cast_to = cam_aim_target.translation
	elif event.is_action_pressed("swap_shoulders"):
		use_left_shoulder = !use_left_shoulder

# Set the appropriate camera zoom and position.
func _process(_delta):
	
	# Object Target Raycasting (for character interactions)
	if (cam_ray.is_colliding()):
		if (cam_ray.get_collider() != target_object):
			target_object = cam_ray.get_collider()
			emit_signal("target_found", target_object)
	elif (target_object != null):
		target_object = null
		emit_signal("target_lost")
	
	if target_actor != null:
		get_node(hud).set_velocity_label(target_actor.velocity)
		
		var pivot_pos = cam_pivot.get_global_transform().origin
		#var offset = cam_point_offset.get_global_transform().origin - pivot_pos
		var offset
		if (use_left_shoulder):
			offset = cam_left_offset.get_global_transform().origin - pivot_pos
		else:
			offset = cam_right_offset.get_global_transform().origin - pivot_pos
		
		var low_pos = cam_point_low.get_global_transform().origin + offset
		var high_pos = cam_point_high.get_global_transform().origin + offset
		translation.x = lerp(low_pos.x, high_pos.x, zoom_level)
		translation.y = lerp(low_pos.y, high_pos.y, zoom_level)
		translation.z = lerp(low_pos.z, high_pos.z, zoom_level)
		look_at(cam_aim_target.get_global_transform().origin, Vector3(0, 1, 0))
		
		#print(cam_ray.transform)#cam_ray.transform.xform(cam_aim_target.transform))
		cam_ray.cast_to = cam_ray.to_local(cam_aim_target.global_transform.origin)

# Turn the cam_pivot based on mouse input and apply a velocity vector to the target actor.
func _physics_process(_delta):
	
	# Construct relevant direction vectors.
	var y_basis = -get_camera_transform().basis.y.normalized()
	var z_basis = -get_camera_transform().basis.z.normalized()
	z_basis += (z_basis - y_basis)
	z_basis = z_basis.normalized()
	var x_basis = -get_camera_transform().basis.x.normalized()
	#var actor_dir = Vector3(target_actor.velocity.x, 0, target_actor.velocity.z).normalized()
	
	# Interpret direction from player inputs.
	var dir = Vector3()
	var is_moving = false
	if Input.is_action_pressed("move_right"):
		is_moving = true
		dir.x -= 1
	if Input.is_action_pressed("move_left"):
		dir.x += 1
		is_moving = true
	if Input.is_action_pressed("move_up"):
		dir.z += 1
		is_moving = true
	if Input.is_action_pressed("move_down"):
		dir.z -= 1
		is_moving = true
	
	# Create direction vector based on camera orientation.
	var vector = Vector3()
	vector += z_basis * dir.z
	vector += x_basis * dir.x
	vector = vector.normalized()
	
#	# Negate actor's current velocity vector.  * NO LONGER NECESSARY *
#	vector += (vector-actor_dir)
#	vector = vector.normalized()
	
	target_actor.apply_velocity_vector(vector, is_moving)

# Returns the object the character is currently looking at.
func get_target_object():
	return target_object

func set_target_actor(actor):
	target_actor = actor
	cam_pivot = actor.cam_pivot
	cam_aim_pivot = actor.cam_aim_pivot
	cam_aim_target = actor.cam_aim_target
	target_height = cam_aim_target.translation.y
	cam_point_low = actor.cam_point_low
	cam_point_high = actor.cam_point_high
	cam_left_offset = actor.cam_left_offset
	cam_right_offset = actor.cam_right_offset
	target_ray = actor.target_ray
