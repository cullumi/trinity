#class_name Resources

extends Node

#TODO:
#- Allow for adding completely new events during runtime.
#- Handle editing of event ids.
#- Allow for object-specific events (through optional object ids)
#- Allow events to trigger other events

# NOTE:  Empty strings are to be ignored in implementation of this data structure.

# Event_Settings is intended be a 2D Array of the following structure:
# + EvID: a unique event id.
# + Type: some functionality type (i.e.: "Interactable", "Button", or "Actor").
# + Role: some object role name.
# + Animation: must be a valid animation name for the object.
# + Effects: particle systems, for example.
# + InCharIDs: some character id (or ids) corresponding to interactable objects that can trigger this event.
# + OutEventIDs: some event id (or ids) corresponding to events that should be triggered by this event.
# + Audio Samples
# + Name

# Standardized Structures
var event_structure : Array = [
	"EvID",
	"Type",
	"Role",
	"Animation",
	"Effects",
	"InCharIDs",
	"OutEventIDs",
	"Exclusive"]

var variation_structure : Array = [
	"Texture",
	"Effects"]

# Defines any restrictions given an interactable type. (Intended for object specifics, such as animations)
var type_restrictions : Dictionary = {
	"Intble":{"Animation":[""]},
	"Button":{"Animation":["","Press Button"]},
	"Actor":{"Animation":["","Pressed"]}}

# Defines valid choices given setting names. 
var setting_choices : Dictionary = {
	"Type":["Intble","Button","Actor"],
	"Texture":["Smooth","Dusty","Splashy"],
	"Role":["","Button","Mayor"],
	"Animation":["","Press Button","Pressed"],
	"Exclusive":[false, true]}

var event_settings : Array = [
	{"EvID":"button-1","Type":"Button", "Role":"Button", "Animation":"Press Button", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":"", "Exclusive":false},
	{"EvID":"button","Type":"Button", "Role":"", "Animation":"Press Button", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":"", "Exclusive":false},
	{"EvID":"p-mayor","Type":"Actor", "Role":"Mayor", "Animation":"Pressed", "Effects":"Prism Poof.tscn", "InCharIDs":"", "OutEventIDs":"", "Exclusive":true},
	{"EvID":"person","Type":"Actor", "Role":"", "Animation":"Pressed", "Effects":"Sphere Poof.tscn", "InCharIDs":"", "OutEventIDs":"", "Exclusive":false}]

var variation_settings : Array = [
	{"Texture":"Dusty", "Effects":"Small Sphere Poof.tscn"},
	{"Texture":"Splashy", "Effects":"Small Water Poof.tscn"}]

# Defines Settings Arrays
var settings_arrays : Dictionary = {
	"Events":event_settings,
	"Variations":variation_settings}

var structure_arrays : Dictionary = {
	"Events":event_structure,
	"Variations":variation_structure}

var default_event_template : Dictionary = {
	"EvID":"",
	"Type":"Intble", 
	"Role":"", 
	"Animation":"", 
	"Effects":"", 
	"InCharIDs":"", 
	"OutEventIDs":"", 
	"Exclusive":false}

var intbles : Array
var char_id_dict : Dictionary = {}
var event_ids : Array = []


# INITIALIZATION

func _ready():
	load_particle_events()
	update_event_choices()
	update_role_choices()
	update_char_id_choices()
	print("Resources Ready")

func update_full():
	update_event_choices()
	update_role_choices()
	update_char_id_choices()

func update_world():
	update_role_choices()
	update_char_id_choices()

func update_event_choices():
	for event in event_settings:
		event_ids.append(event["EvID"])
	setting_choices["OutEventIDs"] = event_ids

func update_intbles():
	intbles = get_tree().get_nodes_in_group("Interactables")

func update_role_choices():
	update_intbles()
	var roles : Array = [""]
	for intble in intbles:
		if (not intble.role in roles):
			roles.append(intble.role)
	setting_choices["Role"] = roles

func update_char_id_choices():
	update_intbles()
	var char_id_intbles : Array = []
	for intble in intbles:
		if (intble.char_id != ""):
			char_id_intbles.append(intble)
	for intble in char_id_intbles:
		char_id_dict[intble.char_id] = intble
	setting_choices["InCharIDs"] = char_id_dict

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
	file_dict[""] = ""
	setting_choices["Effects"] = file_dict


# EVENT FINDERS

#func find_events_by_char_id(object):
#	var rule_sets = []
#	if (object.char_id != ""):
#		for rule_set in event_settings:
#			if (rule_set["InCharIDs"] == object.char_id and rule_set["Type"] == object.type):
#				rule_sets.append(rule_set)
#	return rule_sets
#
#func find_events_by_role(object):
#	var rule_sets = []
#	for rule_set in event_settings:
#		if (rule_set["Role"] == object.role and rule_set["Type"] == object.type):
#			rule_sets.append(rule_set)
#	return rule_sets
#
#func find_events_by_type(object):
#	var rule_sets = []
#	for rule_set in event_settings:
#		if (rule_set["Role"] == "" and rule_set["Type"] == object.type):
#			rule_sets.append(rule_set)
#	return rule_sets

func find_restricted_events(object):
#	var events = find_events_by_char_id(object)
#	if (events == null or events.size() <= 0):
#		events = find_events_by_role(object)
#	if (events == null or events.size() <= 0):
#		events = find_events_by_type(object)
	var events = []
	for event in event_settings:
		if (object.type == event["Type"]):
			if (event["Role"] == "" or object.role == event["Role"]):
				if (event["InCharIDs"] == "" or object.char_id == event["InCharIDs"]):
					events.append(event)
					if (event["Exclusive"]):
						break
	return events

func find_most_restricted_event(object):
	var events = find_restricted_events(object)
	var restricted = []
	for event in events:
		if (object.char_id == event["InCharIDs"]):
			restricted.append(event)
	if (restricted.size() > 0):
		events = restricted.duplicate()
		restricted.clear()
	for event in events:
		if (object.role == event["Role"]):
			restricted.append(event)
	if (restricted.size() > 0):
		return restricted.front()
	elif (events.size() > 0):
		return events.front()
	else:
		return null


# EVENT FUNCTIONS

func get_event_by_id(id):
	for rule_set in event_settings:
		if (rule_set["EvID"] == id):
			return rule_set

func edit_event_by_id(id, setting, new_value):
	for rule_set in event_settings:
		if (rule_set["EvID"] == id):
			rule_set[setting] = new_value
			apply_restrictions_to_event(rule_set)

func edit_event(event, setting, new_value):
	var adjusted_value
	if (setting == "EvID"):
		edit_event_id(new_value, event)
	else:
		event[setting] = new_value
	apply_restrictions_to_event(event)
	adjusted_value = event[setting]
	return adjusted_value

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
	
	if (num != -1):
		id = (id + String(num))
	if (event in event_settings):
		var index = event_ids.find(old_id)
		event_ids.erase(old_id)
		event_ids.insert(index, id)
	event["EvID"] = id
	return id

func apply_restrictions_to_event(event):
	var type = event["Type"]
	for key in event.keys():
		if (key != "EvID"):
			var valid_choices = find_restricted_choices(type, key)
			if (not valid_choices.has(event[key])):
				event[key] = default_event_template[key]


# EVENT MOVEMENT FUNCTIONS

func empty_event(id = null):
	var new_event = default_event_template.duplicate()
	new_event["EvID"] = id
	if (id == null):
		id = "event_0"
		edit_event_id(id, new_event)
		return new_event
	else:
		edit_event_id(id, new_event)
		return new_event

func new_event(id = null):
	return empty_event(id)

func move_event(new_index:int, event):
	var id = event["EvID"]
	event_ids.erase(id)
	event_ids.insert(new_index, id)
	event_settings.erase(event)
	event_settings.insert(new_index, event)

func add_event(event=null):
	if (event == null):
		event = new_event()
	event_settings.append(event)
	setting_choices["OutEventIDs"].append(event["EvID"])

func remove_event(event):
	event_ids.erase(event["EvID"])
	event_settings.erase(event)


# VARIATION FINDERS AND FUNCTIONS

func find_variation_by_texture(texture):
	for variation in variation_settings:
		if (variation["Texture"] == texture):
			return variation
	return null

func find_choices(setting):
	var choices = setting_choices[setting]
	if (choices is Dictionary):
		choices = choices.keys()
	return choices

func edit_variation(variation, setting, new_value):
	variation[setting] = new_value
	return new_value


# VARIATION MOVEMENT FUNCTIONS

func new_variation():
	var new_variation = {"Texture":"Smooth", "Effects":""} 
	return new_variation

func move_variation(new_index:int, variation):
	variation_settings.erase(variation)
	variation_settings.insert(new_index, variation)

func add_variation(variation=null):
	if (variation == null):
		variation = new_variation()
	variation_settings.append(variation)

func remove_variation(variation):
	variation_settings.erase(variation)


# CHOICE AND INTBLE FINDERS

func find_restricted_choices(type, setting):
	var choices = setting_choices[setting]
	if (choices is Dictionary):
		choices = choices.keys()
	if (setting != "Type" and not type_restrictions.keys().has(type)):
		return [""]
	elif (setting == "Type" or not type_restrictions[type].keys().has(setting)):
		return choices
	var restricted : Array = []
	for choice in choices:
		if (type_restrictions[type][setting].has(choice)):
			restricted.append(choice)
	return restricted

func find_restricted_intbles(event):
	var restricted_intbles = []
	for intble in intbles:
		if (intble.type == event["Type"]):
			if (event["Role"] == "" or intble.role == event["Role"]):
				if (event["InCharIDs"] == "" or intble.char_id == event["InCharIDs"]):
					restricted_intbles.append(intble)
	return restricted_intbles


# TEMPLATE CONSTRUCTORS

func construct_button_trigger_pair(triggerer, triggeree):
	var event_1 = new_event(triggerer.char_id)
	var event_2 = new_event(triggeree.char_id)
	event_1.Type = triggerer.type
	event_2.Type = triggeree.type
	event_1.InCharIDs = triggerer.char_id
	event_2.InCharIDs = triggeree.char_id
	event_1.OutEventIDs = event_2.EvID
	add_event(event_1)
	add_event(event_2)
	move_event(0, event_1)
	move_event(1, event_2)
	

# FILTER UTILITIES

func construct_event_filters_from_target(intble):
	var filters : Array = []
	if (intble.char_id != ""):
		filters.append(Filter.new(intble.char_id, false, ["InCharIDs"], true, true, false))
	if (intble.role != ""):
		filters.append(Filter.new(intble.role, false, ["Role"], true, false, false))
	filters.append(Filter.new("", false, ["Role", "InCharIDs", "Exclusive"], true, false, false, intble.type))
	return filters

func construct_variation_filters_from_target(intble):
	var filters : Array = []
	filters.append(Filter.new(intble.texture, false, ["Texture"], true, true, false))
	return filters

# GENERAL UTILITIES

func append_array(array1 : Array, array2 : Array):
	for elem in array2:
		array1.append(elem)
