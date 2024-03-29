# NOT YET READY FOR USE-- STILL EXPERIMENTING

extends Interactable

# Signals
signal target_found
signal target_lost
signal pressed

# Hierarchy
#export var role = "Citizen"
#export var ranks = {"Law":0, "Politics":0, "Crime":0}

# Player Control
export var is_controlled = false
onready var target_ray = get_node("Camera Pivot/TargetRay")
onready var avatar = get_node("Avatar")

# Physics
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

var animation_player = null

func _ready():
	animation_player = get_parent().find_node("AnimationPlayer")

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
		if (velocity.x != 0 and velocity.z != 0):
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

#func press(presser):
#	emit_signal("pressed")
#	if (animation_player != null):
#		animation_player.play("Press")
