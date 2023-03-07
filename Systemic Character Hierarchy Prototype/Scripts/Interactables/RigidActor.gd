extends RigidBody3D

# Signals
#signal target_found
#signal target_lost
signal pressed

# Functionality
@export_enum("RigidActor") var type:String = "RigidActor"
@export_enum("Smooth", "Dusty") var texture:String = "Smooth"

# Identification
@export var char_name:String = "Bob"
@export var char_id:String = ""

# Hierarchy
@export var role:String = "Citizen"
@export var ranks:Dictionary = {"Law":0, "Politics":0, "Crime":0}

# Player Control
@export var is_controlled:bool = false
@onready var target_ray:RayCast3D = get_node("TargetRay")
@onready var avatar = get_node("Avatar")
@onready var collider:CollisionShape3D = $CollisionShape3D

# Physics
var rotation_follow_velocity:bool = true
#var ray_detection_range = 4
var target_object = null
#var move_acceleration = 9.8*2
#var move_deceleration = 9.8*4
#var max_speed = 100
var is_moving:bool = false
var velocity:Vector3 = Vector3(0, 0, 0)
#var UP = Vector3(0, 1, 0)
#var cam_offset = Vector3(1,0,0)
#var gravity_multiplier = 10
#var gravity = -9.8
#var current_grav_velocity = 0

# For Press Events
@onready var animation_player:AnimationPlayer = find_child("AnimationPlayer")
@onready var particle_location:Node3D = find_child("ParticleLocation")

func _ready():
	add_to_group("Interactables")

func _physics_process(_delta):
	pass

# Returns the object the character is currently looking at.
func get_target_object():
	return target_object

# NOTE: Currently here for compatibility purposes.
func apply_velocity_vector(_vector, moving):
	is_moving = moving
	#velocity = vector * move_acceleration

func press(game_event):
	if (animation_player != null and animation_player.is_playing()):
		return
	else:
		populate_game_event(game_event)
		pressed.connect(game_event)
		
func connect_pressed(callable:Callable):
	# warning-ignore:return_value_discarded
	pressed.connect(callable)

func populate_game_event(game_event):
	game_event.pressee = self
	game_event.anim_player = animation_player
	game_event.effect_location = particle_location
