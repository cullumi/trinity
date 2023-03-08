class_name Interactable

extends Node

@export var entity:Entity :
	set(e): entity = e; entity.interactor = self

# Functionality
@onready var type:String :
	set(t): set_on("type", t)
	get: return get_on("type")
@onready var texture:String :
	set(t): set_on("texture", t)
	get: return get_on("texture")

# Identification
@onready var char_name:String :
	set(cn): set_on("char_name", cn)
	get: return get_on("char_name")
@onready var char_id:String :
	set(ci): set_on("char_id", ci)
	get: return get_on("char_id")

# Hierarchy
@onready var role:String :
	set(r): set_on("role", r)
	get: return get_on("role")
@onready var ranks:Dictionary :
	set(r): set_on("ranks", r)
	get: return get_on("ranks", true)

@export var source_node:Node = self # The core node of this interactable
@onready var animation_player:AnimationPlayer = source_node.find_child("AnimationPlayer")
@onready var particle_location:Node3D = source_node.find_child("ParticleLocation")

signal pressed

func set_on(property:String, value):
	if entity: entity[property] = value

func get_on(property:String, dict:bool=false):
	if entity: return entity[property]
	elif dict: return {}
	else: return ""

func _ready():
	if not entity:
		entity = Entity.new()
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
