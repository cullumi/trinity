class_name Actor

extends CharacterBody3D

# Functionality
@export var prepare_back_button_event:bool = true
@export var entity:Entity :
	set(e): entity = e; if interactor: interactor.entity = e;
@onready var interactor:Interactable = %Interactable
@onready var back_button:Interactable = %BackButton

# Player Control
@export var is_controlled = false
@onready var target_ray = %TargetRay
@onready var avatar = %Avatar
@onready var collider = $CollisionShape3D

# Appearance
@onready var body_mesh = $"Avatar/Happy Person"
@onready var smile_center = $"Avatar/Happy Person/Face/Smile"
@onready var smile_left = $"Avatar/Happy Person/Face/Smile/Smile Pivot 1/Smile2"
@onready var smile_right = $"Avatar/Happy Person/Face/Smile/Smile Pivot 2/Smile2"

# Signals
signal target_found
signal target_lost
signal velocity_changed(Vector3)

# Physics
var rotation_follow_velocity = true
var ray_detection_range = 4
var target_object = null
var move_acceleration = 9.8*2
var move_deceleration = 9.8*4
var max_speed = 100
var is_moving = false
var UP = Vector3(0, 1, 0)
var cam_offset = Vector3(1,0,0)
var gravity_multiplier = 10
var gravity = -9.8
var current_grav_velocity = 0
var avatar_bodies : Array = []

func _ready():
	interactor.entity = entity
	randomize_appearance()
	prepare_events()
	for node in avatar.get_children():
		if node is PhysicsBody3D:
			avatar_bodies.append(node)

func prepare_events():
	if (prepare_back_button_event):
		back_button.char_id = "btn-" + interactor.char_id
		Resources.construct_button_trigger_pair(back_button, interactor)

func randomize_appearance():
	randomize()
	var unique_mat = body_mesh.material_override.duplicate()
	var color : Color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	unique_mat.albedo_color = color
	body_mesh.material_override = unique_mat
	smile_center.material_override = unique_mat
	smile_left.material_override = unique_mat
	smile_right.material_override = unique_mat

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
			avatar.look_at(position+look_dir, Vector3.UP)
		# warning-ignore:return_value_discarded
		set_velocity(velocity)
		set_up_direction(UP)
		move_and_slide()

# Returns the object the character is currently looking at.
func get_target_object():
	return target_object

# Adds a given movement velocity to the character.
# Changed "velocity +=" to "velocity =".
# Guarantees that there are no issues with directional movement.
func apply_velocity_vector(vector, moving):
	is_moving = moving
	velocity = vector * move_acceleration
	velocity_changed.emit(velocity)

# Render Layer 0 --> Non-Player / Render Layer 1 --> All Objects
func _make_visible(_visible):
	var avatar_vis_insts : Array = []
	recursive_vis_inst(avatar, avatar_vis_insts)
	for vis_inst in avatar_vis_insts:
		vis_inst.set_layer_mask_value(1, _visible)
		vis_inst.set_layer_mask_value(2, true)

func recursive_vis_inst(node, array):
	for child in node.get_children():
		if child is VisualInstance3D:
			array.append(child)
		recursive_vis_inst(child, array)
