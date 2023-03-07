extends Node3D

@export (Array, NodePath) var particle_systems

func _ready():
	for system in particle_systems:
		get_node(system).emitting = true

func finished():
	queue_free()
