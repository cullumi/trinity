class_name Interactable

extends Node

# Functionality
export (String, "Intble", "Button") var type = "Intble"
export (String, "Smooth", "Dusty") var texture = "Smooth"

# Identification
export (String) var char_name = "Button"
export (String) var char_id = ""

# Hierarchy
export (String) var role = "Button"
export var ranks = {"Law":0, "Politics":0, "Crime":0}

onready var animation_player:AnimationPlayer = find_node("AnimationPlayer")
onready var particle_location:Spatial = find_node("ParticleLocation")

signal pressed

func _ready():
	add_to_group("Interactables")

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
