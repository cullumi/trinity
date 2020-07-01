class_name Resources

extends Node

#TODO:
#- Allow for adding completely new events during runtime.
#- Handle editing of event ids.
#- Allow for object-specific events (through optional object ids)
#- Allow events to trigger other events

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

# Define Valid 
onready var setting_choices : Dictionary = {
	"Type":["Intble","Button","Actor"],
	"Texture":["Smooth","Dusty"],
	"Role":["","Button","Mayor"],
	"Animation":["","Press Button","Pressed"],
	}

var event_settings : Array = [
	{"EvID":"button-1","Type":"Button", "Role":"Button", "Animation":"Press Button", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":""},
	{"EvID":"button","Type":"Button", "Role":"", "Animation":"Press Button", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":""},
	{"EvID":"p-mayor","Type":"Actor", "Role":"Mayor", "Animation":"Pressed", "Effects":"Prism Poof.tscn", "InCharIDs":"", "OutEventIDs":""},
	{"EvID":"person","Type":"Actor", "Role":"", "Animation":"Pressed", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":""}]

var variation_settings : Array = [
	{"Texture":"Dusty", "Effects":"Small Sphere Poof.tscn"}]

var char_id_dict : Dictionary = {}
var event_ids : Array = []

func _ready():
	print("Resources Ready")
	initialize_intble_events()
	for event in event_settings:
		event_ids.append(event["EvID"])
	setting_choices["OutEventIDs"] = event_ids
	load_particle_events()

func initialize_intble_events():
	var intbles = get_tree().get_nodes_in_group("Interactables")
	var roles : Array = [""]
	for intble in intbles:
		if (not intble.role in roles):
			roles.append(intble.role)
	setting_choices["Role"] = roles
	
	var char_id_intbles = []
	for intble in intbles:
		if (intble.char_id != ""):
			char_id_intbles.append(intble)
	for intble in char_id_intbles:
		char_id_dict[intble.char_id] = intble
	setting_choices["InCharIDs"] = char_id_dict

func load_particle_events():
	var file_dict = Dictionary()
	var dir : Directory = Directory.new()
	# warning-ignore:return_value_discarded
	dir.open("res://Scenes/Particle Systems/Particle Events")
	# warning-ignore:return_value_discarded
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") and not dir.current_is_dir():
			file_dict[file] = dir.get_current_dir()
	dir.list_dir_end()
	file_dict[""] = ""
	setting_choices["Effects"] = file_dict

func find_settings_by_char_id(object):
	if (object.char_id != ""):
		for rule_set in event_settings:
			if (rule_set["InCharIDs"] == object.char_id and rule_set["Type"] == object.type):
				return rule_set
	return null

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
	var settings = find_settings_by_char_id(object)
	if (settings == null):
		settings = find_settings_by_role(object)
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

func edit_event_id(new_id, event):
	var old_id = event["EvID"]
	var id = new_id
	var num = -1
	var done = false
	while not done:
		done = true
		for ev in event_settings:
			if (ev == event):
				continue
			var ev_id : String = ev["EvID"]
			if (num == -1 and ev_id == new_id):
				print(ev_id + "  /  " + ev_id.right(ev_id.length()-1))
				if (ev_id.right(ev_id.length()-1).is_valid_integer()):
					print(new_id.left(new_id.length()-1))
					id = new_id.left(new_id.length()-1)
				num = num+1
				done = false
				break
			elif (ev_id == (id + String(num))):
				num = num+1
				done = false
				break
	if (num == -1):
		event["EvID"] = id
	else:
		event["EvID"] = (id + String(num))
	if (event in event_settings):
		var index = event_ids.find(old_id)
		event_ids.erase(old_id)
		event_ids.insert(index, id)
	return id

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

func empty_event(id = null):
	var new_event = {"EvID":id,"Type":"Intble", "Role":"", "Animation":"", "Effects":"", "InCharIDs":"", "OutEventIDs":""} 
	if (id == null):
		id = "event_0"
		edit_event_id(id, new_event)
		return new_event
	else:
		edit_event_id(id, new_event)
		return new_event

func add_event(event):
	event_settings.append(event)
	setting_choices["OutEventIDs"].append(event["EvID"])
