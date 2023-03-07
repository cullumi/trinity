extends Node3D

class_name PlayerCamera

# Scripts

# Camera3D Components
@onready var camera = %Camera
@onready var cam_pivot = %CameraPivot
@onready var fp_pivot = %"FP Pivot"
@onready var fp_aim = %"FP Target"
@onready var tp_pivot = %"TP Pivot"
@onready var tp_low = %"TP Low".transform.origin
@onready var tp_high = %"TP High".transform.origin
@onready var tp_aim = %"TP Target"
@onready var tp_left_offset = %"Left Offset".transform.origin
@onready var tp_center_offset = %"Center Offset".transform.origin
@onready var tp_right_offset = %"Right Offset".transform.origin
@onready var aim_ray : RayCast3D = %RayCast

# Settings
@export var hud:NodePath
@export var start_in_first_person:bool = true
@export var upper_view_limit:float = 15
@export var lower_view_limit:float = 3
@export var mouse_sensitivity:float = 0.1
@export var zoom_sensitivity:float = 2
@export var mid_offset:float = 0

# Signals
signal target_found
signal target_lost
signal ray_event

# Player Objects
var player_actor = null
var player_avatar = null

# Runtime Variables
var target_object = null
@onready var aim_height = tp_aim.transform.origin.y
var aim_ray_triggered = false
var zoom_mode_active = false
var zoom_level = 0
var first_person = false
var over_shoulder = false
var use_left_shoulder = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if (start_in_first_person):
		first_person = true

# Player Inputs
func _input(event):
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		# Perspective Cycling
		if event.is_action_pressed("swap_view"):
			cycle_perspectives()
		# Mouse Movements --> First vs Third Person Aiming
		elif event is InputEventMouseMotion:
			if (first_person):
				fp_aiming(event)
			else:
				tp_aiming(event)
		# Scroll Wheel --> UI Focus vs Camera3D Zoom
		elif event.is_action_pressed("zoom_mode"):
			zoom_mode_active = true
		elif event.is_action_released("zoom_mode"):
			zoom_mode_active = false

# Raycast pinging and camera perspective updates.
func _process(_delta):
	if player_actor != null:
		# Raycast Collisions
		ping_aim_raycast()
		# Camera3D Positioning and Aiming
		if (first_person):
			update_fp_camera()
		else:
			update_tp_camera()

# Controls movement of the player actor.
func _physics_process(_delta):
	# Construct relevant direction vectors.
	var y_basis = -camera.get_camera_transform().basis.y.normalized()
	var z_basis = -camera.get_camera_transform().basis.z.normalized()
	z_basis += (z_basis - y_basis)
	z_basis = z_basis.normalized()
	var x_basis = -camera.get_camera_transform().basis.x.normalized()
	
	# Interpret direction from player inputs.
	var dir = Vector3()
	var is_moving = false
	
	if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
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
	
	# Create direction vector based on horizontal camera orientation.
	var vector = Vector3()
	vector += Vector3(z_basis.x,0,z_basis.z) * dir.z
	vector += Vector3(x_basis.x,0,x_basis.z) * dir.x
	vector = vector.normalized()
	
	player_actor.apply_velocity_vector(vector, is_moving)
	
	# Report velocity to the hud -- TODO: change to retrieval by world object?
	get_node(hud).velocity = player_actor.velocity

# Creates and parses an input action event.
func trigger_input_action(action, pressed):
	var event = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)

# Zooming
func zoom(zoom_in:bool):
	if zoom_mode_active:
		var dir = -1 if zoom_in else 1
		zoom_level += dir * zoom_sensitivity * get_process_delta_time()
		zoom_level = clamp(zoom_level, 0, 1)

# Returns the object the player is aiming at.
func get_target_object():
	return target_object

# Used when swapping characters
func set_player_actor(actor):
	aim_ray.clear_exceptions()
	if (player_actor != null):
		player_actor._make_visible(true)
	player_actor = actor
	player_avatar = actor.avatar
	player_actor._make_visible(false)
	aim_ray.add_exception(player_actor)
	for body in player_actor.avatar_bodies:
		aim_ray.add_exception(body)
	update_perspective()

# Cycles through first person as well as third person left/center/right perspectives.
func cycle_perspectives():
	if (first_person):
		first_person = false
		over_shoulder = true
		use_left_shoulder = true
		if (!player_avatar.visible):
			player_avatar.visible = true
	elif (over_shoulder):
		if (use_left_shoulder):
			over_shoulder = false
		else:
			first_person = true
			over_shoulder = false
			if (player_avatar.visible):
				player_avatar.visible = false
	else:
		over_shoulder = true
		use_left_shoulder = false
	update_perspective()

func update_perspective():
	if (first_person):
		player_avatar.visible = false
		player_actor.rotation_follow_velocity = false
	else:
		player_avatar.visible = true
		player_actor.rotation_follow_velocity = true

# Handle collisions from the raycast used for aiming.
func ping_aim_raycast():
	# Player Crosshair Raycasting (for character interactions)
	if (aim_ray.is_colliding()):
		if (aim_ray.get_collider() != target_object):
			target_object = aim_ray.get_collider()
			target_found.emit(target_object)
	elif (target_object != null):
		target_object = null
		target_lost.emit(target_object)

func trigger_ray_event():
	var event = RayCastEvent.new()
	event.collider = target_object
	event.collision_normal = aim_ray.get_collision_normal()
	event.collision_point = aim_ray.get_collision_point()
	emit_signal("ray_event", event)

# Handles aiming inputs as if in first person mode.
func fp_aiming(event):
	cam_pivot.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))
	fp_pivot.rotate_x (deg_to_rad(event.relative.y * mouse_sensitivity * -1))
	fp_pivot.rotation_degrees.x = clamp(fp_pivot.rotation_degrees.x, -75, 75)
	var global_look = fp_aim.global_transform.origin
	aim_ray.target_position = aim_ray.to_local(global_look)
	var actor_look = Vector3(global_look.x, 0, global_look.z)
	player_actor.look_at(actor_look, Vector3.UP)

# Sets up proper camera positioning for first person mode.
func update_fp_camera():
	cam_pivot.global_transform.origin = player_actor.global_transform.origin 
	camera.transform = fp_pivot.transform
	aim_ray.transform.origin = fp_pivot.transform.origin

# Handles aiming inputs as if in third person mode.
func tp_aiming(event):
	cam_pivot.rotate_y(deg_to_rad(event.relative.x * mouse_sensitivity * -1))
	tp_aim.translate(Vector3(0, event.relative.y * 0.1 * mouse_sensitivity * -1, 0))
	var low_aim_height = aim_height-lower_view_limit
	var high_aim_height = aim_height+upper_view_limit
	tp_aim.position.y = clamp(tp_aim.position.y, low_aim_height, high_aim_height)
	aim_ray.target_position = aim_ray.to_local(tp_aim.global_transform.origin)

# Sets up proper camera positioning for third person mode.
func update_tp_camera():
	cam_pivot.global_transform.origin = player_actor.global_transform.origin
	
	# Camera3D Pivot and Offset
	var offset = Vector3()
	if (over_shoulder):
		if (use_left_shoulder):
			offset = tp_left_offset
		else:
			offset = tp_right_offset
	else:
		offset = tp_center_offset
			
	# Final Camera3D Position Based on Zoom Level
	var low_pos = tp_pivot.transform.origin + tp_low + offset
	var high_pos = tp_pivot.transform.origin + tp_high + offset
	camera.position.x = lerp(low_pos.x, high_pos.x, zoom_level)
	camera.position.y = lerp(low_pos.y, high_pos.y, zoom_level)
	camera.position.z = lerp(low_pos.z, high_pos.z, zoom_level)
			
	# Camera3D Direction and Crosshair Raycast
	camera.look_at(tp_aim.get_global_transform().origin, Vector3(0, 1, 0))
	aim_ray.target_position = aim_ray.to_local(tp_aim.global_transform.origin)
