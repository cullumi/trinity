extends Camera3D

# Object Targeting
signal target_found
signal target_lost

@export (NodePath) var hud
@export (bool) var start_in_first_person = true
@export (bool) var first_person = false
@export (bool) var over_shoulder = true
@export (bool) var use_left_shoulder = true
@export (float) var upper_view_limit = 15
@export (float) var lower_view_limit = 3

# Target Actors
var target_actor = null
var player_avatar
var cam_fp_pos
var cam_fp_target
var cam_pivot
var cam_aim_pivot
var cam_aim_target
var cam_point_low
var cam_point_high
var cam_center_offset
var cam_left_offset
var cam_right_offset
var target_ray
@onready var cam_ray = get_node("RayCast3D")

# Assigned Variables
var target_object = null
var target_height
var target_ray_triggered = false
var zoom_mode_active = false

# Sensitivities and Settings
var mouse_sensitivity = 0.1
var zoom_sensitivity = 2
var zoom_level = 0
var cam_mid_offset = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (start_in_first_person):
		first_person = true
		over_shoulder = false

# Player Inputs
func _input(event):
	# UI Selection
	if event.is_action_pressed("select"):
		var select = InputEventAction.new()
		select.action = "ui_accept"
		select.button_pressed = true
		Input.parse_input_event(select)
	elif event.is_action_released("select"):
		var select = InputEventAction.new()
		select.action = "ui_accept"
		select.button_pressed = false
		Input.parse_input_event(select)
	# Scroll Wheel --> UI Focus vs Camera3D Zoom
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
			next.button_pressed = true
			Input.parse_input_event(next)
			next.button_pressed = false
			Input.parse_input_event(next)
	elif event.is_action_pressed("scroll_up"):
		if zoom_mode_active:
			zoom_level -= zoom_sensitivity * get_process_delta_time()
			zoom_level = clamp(zoom_level, 0, 1)
		else:
			var prev = InputEventAction.new()
			prev.action = "ui_focus_prev"
			prev.button_pressed = true
			Input.parse_input_event(prev)
			prev.button_pressed = false
			Input.parse_input_event(prev)
	# Mouse Movements --> First vs Third Person Camera3D
	elif event is InputEventMouseMotion:
		cam_pivot.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))
		
		if (first_person):
			cam_fp_pos.rotate_x (deg_to_rad(event.relative.y * mouse_sensitivity * -1))
			cam_fp_pos.rotation_degrees.x = clamp(cam_fp_pos.rotation_degrees.x, -75, 75)
			target_ray.target_position = target_ray.to_local(cam_fp_target.global_transform.origin)
		else:
			cam_aim_target.translate(Vector3(0, event.relative.y * 0.1 * mouse_sensitivity * -1, 0))
			var low_target_height = target_height-lower_view_limit
			var high_target_height = target_height+upper_view_limit
			cam_aim_target.position.y = clamp(cam_aim_target.position.y, low_target_height, high_target_height)
			target_ray.target_position = target_ray.to_local(cam_aim_target.global_transform.origin)
	# View Swapping
	elif event.is_action_pressed("swap_view"):
		if (first_person):
			first_person = false
			over_shoulder = true
			use_left_shoulder = true
		elif (over_shoulder):
			if (use_left_shoulder):
				over_shoulder = false
			else:
				first_person = true
				over_shoulder = false
		else:
			over_shoulder = true
			use_left_shoulder = false

# Set the appropriate camera zoom, positioning, and Crosshair Raycast
func _process(_delta):
	
	# Player Crosshair Raycasting (for character interactions)
	if (target_ray.is_colliding()):
		if (target_ray.get_collider() != target_object):
			target_object = target_ray.get_collider()
			emit_signal("target_found", target_object)
	elif (target_object != null):
		target_object = null
		emit_signal("target_lost")
	
	if target_actor != null:
		get_node(hud).set_velocity_label(target_actor.velocity)
		
		if (first_person):
			# Simple First Person Camera3D Positioning
			if (player_avatar.visible):
				player_avatar.visible = false
			global_transform = cam_fp_pos.get_global_transform()
		else:
			if (!player_avatar.visible):
				player_avatar.visible = true
			
			# Camera3D Pivot and Offset
			var pivot_pos = cam_pivot.get_global_transform().origin
			var offset = Vector3()
			if (over_shoulder):
				if (use_left_shoulder):
					offset = cam_left_offset.get_global_transform().origin - pivot_pos
				else:
					offset = cam_right_offset.get_global_transform().origin - pivot_pos
			else:
				offset = cam_center_offset.get_global_transform().origin - pivot_pos
			
			# Final Camera3D Position Based on Zoom Level
			var low_pos = cam_point_low.get_global_transform().origin + offset
			var high_pos = cam_point_high.get_global_transform().origin + offset
			position.x = lerp(low_pos.x, high_pos.x, zoom_level)
			position.y = lerp(low_pos.y, high_pos.y, zoom_level)
			position.z = lerp(low_pos.z, high_pos.z, zoom_level)
			
			# Camera3D Direction and Crosshair Raycast
			look_at(cam_aim_target.get_global_transform().origin, Vector3(0, 1, 0))
			cam_ray.target_position = cam_ray.to_local(cam_aim_target.global_transform.origin)

# Turn the camera pivot based on mouse input and apply a velocity vector to the player actor.
func _physics_process(_delta):
	
	# Construct relevant direction vectors.
	var y_basis = -get_camera_transform().basis.y.normalized()
	var z_basis = -get_camera_transform().basis.z.normalized()
	z_basis += (z_basis - y_basis)
	z_basis = z_basis.normalized()
	var x_basis = -get_camera_transform().basis.x.normalized()
	
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
	vector += Vector3(z_basis.x,0,z_basis.z) * dir.z
	vector += Vector3(x_basis.x,0,x_basis.z) * dir.x
	vector = vector.normalized()
	
	target_actor.apply_velocity_vector(vector, is_moving)

# Used to returns the object the Player is currently looking at.
func get_target_object():
	return target_object

# Used when swapping characters
func set_target_actor(actor):
	target_actor = actor
	player_avatar = actor.avatar
	cam_pivot = actor.cam_pivot
	cam_aim_pivot = actor.cam_aim_pivot
	cam_aim_target = actor.cam_aim_target
	target_height = cam_aim_target.position.y
	cam_point_low = actor.cam_point_low
	cam_point_high = actor.cam_point_high
	cam_center_offset = actor.cam_center_offset
	cam_left_offset = actor.cam_left_offset
	cam_right_offset = actor.cam_right_offset
	target_ray = actor.target_ray
	cam_fp_pos = actor.cam_fp_pos
	cam_fp_target = actor.cam_fp_target
