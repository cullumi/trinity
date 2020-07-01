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
# + Audio Samples

var type_restrictions : Dictionary = {
	"Intble":{"Animation":[""]},
	"Button":{"Animation":["","Press Button"]},
	"Actor":{"Animation":["","Pressed"]}}

var setting_choices : Dictionary = {
	"Type":["Intble","Button","Actor"],
	"Texture":["Smooth","Dusty"],
	"Role":["","Button","Mayor"],
	"Animation":["","Press Button","Pressed"]}

var event_settings : Array = [
	{"EvID":"button-1","Type":"Button", "Role":"Button", "Animation":"Press Button", "Effects":"Sphere Poof.tscn"},
	{"EvID":"button","Type":"Button", "Role":"", "Animation":"Press Button", "Effects":"Sphere Poof.tscn"},
	{"EvID":"p-mayor","Type":"Actor", "Role":"Mayor", "Animation":"Pressed", "Effects":"Prism Poof.tscn"},
	{"EvID":"person","Type":"Actor", "Role":"", "Animation":"Pressed", "Effects":"Sphere Poof.tscn"}]

var variation_settings : Array = [
	{"Texture":"Dusty", "Effects":"Small Sphere Poof.tscn"}]

func _ready():
	print("Resources Ready")
	load_particle_events()

func load_particle_events():

	var file_dict = Dictionary()
	var dir : Directory = Directory.new()
	dir.open("res://Scenes/Particle Systems/Particle Events")
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not dir.current_is_dir():
			file_dict[file] = dir.get_current_dir()
			
	dir.list_dir_end()
	
	setting_choices["Effects"] = file_dict

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

func get_event_by_id(id):
	for rule_set in event_settings:
		if (rule_set["EvID"] == id):
			return rule_set

func edit_event_by_id(id, setting, new_value):
	for rule_set in event_settings:
		if (rule_set["EvID"] == id):
			rule_set[setting] = new_value
			apply_restrictions_to_event(rule_set)

func apply_restrictions_to_event(event):
	var type = event["Type"]
	for key in event.keys():
		if (key != "EvID"):
			var valid_choices = find_restricted_choices(type, key)
			if (not valid_choices.has(event[key])):
				event[key] = ""

func find_restricted_choices(type, setting):
	var choices = setting_choices[setting]
	if (setting != "Type" and not type_restrictions.keys().has(type)):
		return [""]
	elif (setting == "Type" or not type_restrictions[type].keys().has(setting)):
		return choices
	var restricted : Array = []
	for choice in choices:
		if (type_restrictions[type][setting].has(choice)):
			restricted.append(choice)
	return restricted
