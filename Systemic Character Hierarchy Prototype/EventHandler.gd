extends Node

export (bool) var dynamic_particles
var resources: Resources

func trigger_press_event(press_event:GameEvent):
	var object = press_event.pressee
	var settings = resources.find_most_restrictive_settings(object)
	if (settings != null):
		
		# Animation
		var animation_player: AnimationPlayer = press_event.anim_player
		var animation: String = settings["Animation"]
		if (animation_player != null and animation != ""):
			animation_player.play(animation)
		
		# Effects
		var particle_loc: Spatial = press_event.effect_location
		var particle_scene: PackedScene = null
		if (settings["Effects"] != ""):
			particle_scene = load(resources.setting_choices["Effects"][settings["Effects"]] + "/" + settings["Effects"])
		if (particle_loc != null and particle_scene != null):
			var particles = particle_scene.instance()
			particle_loc.add_child(particles)
			particles.translation = Vector3()
			if (dynamic_particles):
				particles.process_material.gravity = -9.8 * particles.to_local(particles.global_transform.origin + Vector3.UP)
			#particles.emitting = true
	
	# Collision Point Effects
	var point = press_event.press_point
	var variation = resources.find_variation_by_texture(object.texture)
	var effect_scene = null
	if (point != null and variation != null):
		if (variation["Effects"] != ""):
			effect_scene = load(resources.setting_choices["Effects"][variation["Effects"]] + "/" + variation["Effects"])
		if (effect_scene != null):
			var particles = effect_scene.instance()
			get_tree().root.add_child(particles)
			var normal = press_event.press_normal
			var up_vector = point-Vector3(normal.y,-normal.x,-normal.z)
			particles.look_at_from_position(point, point-normal, up_vector)
			#particles.look_at(point - normal, particles.global_transform.basis.y.normalized())
			if (dynamic_particles):
				particles.process_material.gravity = -9.8 * particles.to_local(particles.global_transform.origin + Vector3.UP)
			#particles.emitting = true
