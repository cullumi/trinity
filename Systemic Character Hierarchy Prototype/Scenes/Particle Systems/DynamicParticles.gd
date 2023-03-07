extends Particles

@export (bool) var dynamic_gravity

func _ready():
	pass#process_material.gravity = -9.8 * to_local(Vector3.UP)

func _process(delta):
	if (dynamic_gravity):
		#process_material.gravity = -9.8 * to_local(Vector3.UP)
		pass
