 extends KinematicBody

# Object Targeting
signal target_found
signal target_lost

# Hierarchy
export var role = "Citizen"
export var ranks = {"Law":0, "Politics":0, "Crime":0}

# Player Control
export var is_controlled = false
onready var cam_pivot = get_node("Camera Pivot")
onready var cam_aim_target = get_node("Camera Pivot/Camera Aim Target")
onready var cam_aim_pivot = get_node("Camera Pivot/Camera Aim Pivot")
onready var cam_point_low = get_node("Camera Pivot/Camera Aim Pivot/Camera Point Low")
onready var cam_point_high = get_node("Camera Pivot/Camera Aim Pivot/Camera Point High")
onready var cam_left_offset = get_node("Camera Pivot/Camera Left Offset")
onready var cam_right_offset = get_node("Camera Pivot/Camera Left Offset/Camera Right Offset")
onready var target_ray = get_node("Camera Pivot/TargetRay")
onready var test_ray = get_node("TestCast")
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

# Handles Velocity Limits and Cancelers as well as Raycast Positioning.
func _physics_process(_delta):

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
#	if !is_on_floor():
#		velocity.y -= 9.8 * delta
#
#		if velocity.y < -53:
#			velocity.y = -53
#	else:
#		velocity.y = 0
#		if velocity.y > -.64 and velocity.y < .64:
#			velocity.y = 0
	
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
		#test_ray.cast_to = velocity
		velocity.y = 0
		avatar.look_at(translation+velocity, Vector3.UP)
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
