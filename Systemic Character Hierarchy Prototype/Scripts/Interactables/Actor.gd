class_name Actor

extends KinematicBody

# Signals
signal target_found
signal target_lost
signal pressed

# Functionality
export (String, "Actor") var type = "Actor"
export (String, "Smooth", "Dusty", "Splashy") var texture = "Smooth"
export (bool) var prepare_back_button_event = true
onready var back_button = $Avatar/Button

# Identification
export (String) var char_name = "Bob"
export (String) var char_id = ""

# Hierarchy
export (String) var role = "Citizen"
export var ranks = {"Law":0, "Politics":0, "Crime":0}

# Player Control
export var is_controlled = false
onready var target_ray = get_node("TargetRay")
onready var avatar = get_node("Avatar")
onready var collider = $CollisionShape

# Appearance
onready var body_mesh = $"Avatar/Happy Person"
onready var smile_center = $"Avatar/Happy Person/Face/Smile"
onready var smile_left = $"Avatar/Happy Person/Face/Smile/Smile Pivot 1/Smile2"
onready var smile_right = $"Avatar/Happy Person/Face/Smile/Smile Pivot 2/Smile2"

# Physics
var rotation_follow_velocity = true
var ray_detection_range = 4
var target_object = null
var move_acceleration = 9.8*2
var move_deceleration = 9.8*4
var max_speed = 100
var is_moving = false
var velocity = Vector3(0, 0, 0)
var UP = Vector3(0, 1, 0)
var cam_offset = Vector3(1,0,0)
var gravity_multiplier = 10
var gravity = -9.8
var current_grav_velocity = 0
var avatar_bodies : Array = []

# For Press Events
onready var animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var particle_location:Spatial = find_node("ParticleLocation")

func _ready():
	randomize_appearance()
	add_to_group("Interactables")
	prepare_events()
	for node in avatar.get_children():
		if node is PhysicsBody:
			avatar_bodies.append(node)

func prepare_events():
	if (prepare_back_button_event):
		if (char_id == ""):
			char_id = char_name
		back_button.char_id = "btn-" + char_id
		Resources.construct_button_trigger_pair(back_button, self)

func randomize_appearance():
	randomize()
	var unique_mat = body_mesh.get_surface_material(0).duplicate()
	var color : Color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0, 1))
	unique_mat.albedo_color = color
	body_mesh.set_surface_material(0, unique_mat)
	smile_center.set_surface_material(0, unique_mat)
	smile_left.set_surface_material(0, unique_mat)
	smile_right.set_surface_material(0, unique_mat)

# Handles Velocity Limits and Cancelers as well as Raycast Positioning.
func _physics_process(delta):

	# Object Target Raycasting (for character interactions)
	if (target_ray.is_colliding() and is_controlled):
		if (target_ray.get_collider() != target_object):
			target_object = target_ray.get_collider()
			emit_signal("target_found", target_object)
	elif (target_object != null):
		target_object = null
		emit_signal("target_lost")
	
	# Y-Velocity Gravity, Limits, and Cancelers.
	# ** Currently Not in Use **
	if !is_on_floor():
		current_grav_velocity += gravity * gravity_multiplier * delta
		velocity.y += current_grav_velocity
		if velocity.y < -53:
			velocity.y = -53
	else:
		current_grav_velocity = 0
		if velocity.y > -.64 and velocity.y < .64:
			velocity.y = 0
	
	# X/Z-Velocity Cancelers
	if !is_moving:
		if velocity.x > -.64 and velocity.x < .64:
			velocity.x = 0
		if velocity.z > -.64 and velocity.z < .64:
			velocity.z = 0
		if velocity.x >= -10 and velocity.x <= 10:
			velocity.x = 0
		if velocity.z >= -10 and velocity.z <= 10:
			velocity.z = 0
	
	if velocity != Vector3():
		
		# X/Z-Velocity Limits
		if velocity.x > max_speed:
			velocity.x = max_speed
		elif velocity.x < -max_speed:
			velocity.x = -max_speed
		if velocity.z > max_speed:
			velocity.z = max_speed
		elif velocity.z < -max_speed:
			velocity.z = -max_speed
		
		# Final Movement / Raycasting
		if (velocity.x != 0 and velocity.z != 0 and rotation_follow_velocity):
			var look_dir = Vector3(velocity.x, 0, velocity.z)
			avatar.look_at(translation+look_dir, Vector3.UP)
		# warning-ignore:return_value_discarded
		move_and_slide(velocity, UP)

# Returns the object the character is currently looking at.
func get_target_object():
	return target_object

# Adds a given movement velocity to the character.
# Changed "velocity +=" to "velocity =".
# Guarantees that there are no issues with directional movement.
func apply_velocity_vector(vector, moving):
	is_moving = moving
	velocity = vector * move_acceleration

func press(game_event):
	if (animation_player != null and animation_player.is_playing()):
		return
	else:
		populate_game_event(game_event)
		emit_signal("pressed", game_event)
		
func connect_pressed(event_handler, signal_method):
	# warning-ignore:return_value_discarded
	connect("pressed", event_handler, signal_method)

func populate_game_event(game_event):
	game_event.pressee = self
	game_event.anim_player = animation_player
	game_event.effect_location = particle_location

# Render Layer 0 --> Non-Player / Render Layer 1 --> All Objects
func make_visible(is_visible):
	var avatar_vis_insts : Array = []
	recursive_vis_inst(avatar, avatar_vis_insts)
	for vis_inst in avatar_vis_insts:
		vis_inst.set_layer_mask_bit(0, is_visible)
		vis_inst.set_layer_mask_bit(1, true)

func recursive_vis_inst(node, array):
	for child in node.get_children():
		if child is VisualInstance:
			array.append(child)
		recursive_vis_inst(child, array)
