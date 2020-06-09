class_name Resources

extends Node

# NOTE:  Empty strings are to be ignored in implementation of this data structure.

# Intended be a 2D Array of the following structure:
# + Type: some functionality type (i.e.: "Interactable", "Button", or "Actor")
# + Role: some object role name.
# + Name: some object name.
# + ID: some instance id (must have been assigned)
# + Animation: must be a valid animation name for the object.
# + Effects: particle systems, for example.
# + Effects: particle systems, for example.

export (Array) var event_settings = [
	{"Type":"Button", "Role":"Button", "Animation":"Press Button", "Effects":"res://Scenes/Particle Systems/Sphere Poof.tscn"},
	{"Type":"Button", "Role":"", "Animation":"Press Button", "Effects":"res://Scenes/Particle Systems/Sphere Poof.tscn"},
	{"Type":"Actor", "Role":"Mayor", "Animation":"Pressed", "Effects":"res://Scenes/Particle Systems/Prism Poof.tscn"},
	{"Type":"Actor", "Role":"", "Animation":"Pressed", "Effects":"res://Scenes/Particle Systems/Sphere Poof.tscn"}]

export (Array) var variation_settings = [
	{"Texture":"Dusty", "Effects":"res://Scenes/Particle Systems/Small Sphere Poof.tscn"}]

func find_settings_by_role(object):
	for rule_set in event_settings:
		if (rule_set["Role"] == object.role and rule_set["Type"] == object.type):
			return rule_set
	return null

func find_settings_by_type(object):
	for rule_set in event_settings:
		if (rule_set["Role"] == "" and rule_set["Type"] == object.type):
			return rule_set
	return null

func find_most_restrictive_settings(object):
	var settings = find_settings_by_role(object)
	if (settings == null):
		settings = find_settings_by_type(object)
	return settings

func find_variation_by_texture(texture):
	for variation in variation_settings:
		if (variation["Texture"] == texture):
			return variation
	return null
