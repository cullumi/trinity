extends Node

@export (bool) var dynamic_particles

# Pass in a game event
func trigger_press_event(press_event:GameEvent):
	var pressee = press_event.pressee
#	var settings = Resources.find_first_restrictive_event(pressee)
	var events = Resources.find_restricted_events(pressee)
	if (events != null):
		#perform_event_on_object(events, press_event)
		for event in events:
			perform_event_on_object(event, press_event)
	
	# Collision Point Effects
	var point = press_event.press_point
	var variation = Resources.find_variation_by_texture(pressee.texture)
	var effect_scene = null
	if (point != null and variation != null):
		if (variation["Effects"] != ""):
			effect_scene = load(Resources.setting_choices["Effects"][variation["Effects"]] + "/" + variation["Effects"])
		if (effect_scene != null):
			var particles = effect_scene.instantiate()
			get_tree().root.add_child(particles)
			var normal = press_event.press_normal
			var up_vector = point-Vector3(normal.y,-normal.x,-normal.z)
			particles.look_at_from_position(point, point-normal, up_vector)
			#particles.look_at(point - normal, particles.global_transform.basis.y.normalized())
			if (dynamic_particles):
				particles.process_material.gravity = -9.8 * particles.to_local(particles.global_transform.origin + Vector3.UP)
			#particles.emitting = true

# Pass in an event with a press_event or valid interactable.
func perform_event_on_object(settings, press_event):
	
	# Find Anim Player and Effect Location
	var anim_player : AnimationPlayer
	var effect_location : Node3D
	if (press_event is GameEvent):
		anim_player = press_event.anim_player
		effect_location = press_event.effect_location
	elif (press_event is Actor or press_event is Interactable):
		anim_player = press_event.animation_player
		effect_location = press_event.particle_location
	
	# Animation
	var animation_player: AnimationPlayer = anim_player
	var animation: String = settings["Animation"]
	if (animation_player != null and animation != ""):
		animation_player.play(animation)
	
	# Effects
	var particle_loc: Node3D = effect_location
	var particle_scene: PackedScene = null
	if (settings["Effects"] != ""):
		particle_scene = load(Resources.setting_choices["Effects"][settings["Effects"]] + "/" + settings["Effects"])
	if (particle_loc != null and particle_scene != null):
		var particles = particle_scene.instantiate()
		particle_loc.add_child(particles)
		particles.position = Vector3()
		if (dynamic_particles):
			particles.process_material.gravity = -9.8 * particles.to_local(particles.global_transform.origin + Vector3.UP)
	
	# Event Triggers
	if (settings["OutEventIDs"] != ""):
		var event_id = settings["OutEventIDs"]
		var event = Resources.get_event_by_id(event_id)
		var intbles = Resources.find_restricted_intbles(event)
		for intble in intbles:
			perform_event_on_object(event, intble)
