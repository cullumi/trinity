class_name Interactable

extends Node

# Functionality
@export_enum("Intble", "Button", "Actor") var type:String = "Intble"
@export_enum("Smooth", "Dusty", "Splashy") var texture:String = "Smooth"

# Identification
@export var char_name:String = "Button"
@export var char_id:String = ""

# Hierarchy
@export var role:String = "Button"
@export var ranks:Dictionary = {"Law":0, "Politics":0, "Crime":0}

@export var source_node:Node = self # The core node of this interactable
@onready var animation_player:AnimationPlayer = source_node.find_child("AnimationPlayer")
@onready var particle_location:Node3D = source_node.find_child("ParticleLocation")

signal pressed

func _ready():
	add_to_group("Interactables")
	if (char_id == ""):
		char_id = char_name

func press(game_event):
	if (animation_player != null and animation_player.is_playing()):
		return
	else:
		populate_game_event(game_event)
		pressed.emit(game_event)

func connect_pressed(callable:Callable):
	# warning-ignore:return_value_discarded
	pressed.connect(callable)

func populate_game_event(game_event):
	game_event.pressee = self
	game_event.anim_player = animation_player
	game_event.effect_location = particle_location
