class_name EventItemEditor

extends Control

onready var ev_id = $"Top Row/EvID"
onready var ev_type = $"Top Row/Type"
onready var ev_role = $"Top Row/Role"
onready var ev_anim = $"Top Row/Animation"
onready var ev_fx = $"Top Row/Effects"
onready var ev_iCIDs = $"Bottom Row/InCharIDs"
onready var ev_oEIDs = $"Bottom Row/OutEventIDs"
onready var ev_excl = $"Bottom Row/Exclusive?"
onready var events = Resources.event_settings

signal filter
signal unfilter

var fields = []
var ev_structure = Resources.event_structure
var event
var index
var id
var has_been_initialized = false

func _ready():
	initialize()

func initialize():
	if (index != null):
		if (index < events.size() and index >= 0):
			event = events[index]
		else:
			event = Resources.new_event(id)
			Resources.add_event(event)
		
		fields.append(ev_id)
		recursive_append_menu_buttons(self, fields)
		ev_id.connect("text_entered", self, "change_event", ["EvID",ev_id])
		ev_id.connect("focus_exited", self, "change_event", [null,"EvID",ev_id])
		for idx in range(1, ev_structure.size()-1):
			var popup = fields[idx].get_popup()
			var signal_info = [ev_structure[idx], fields[idx]]
			popup.connect("index_pressed", self, "change_event", signal_info)
		ev_excl.connect("toggled", self, "change_event", ["Exclusive", ev_excl])
	
		update_contents()
		has_been_initialized = true

func recursive_append_menu_buttons(node:Node, array:Array):
	for child in node.get_children():
		if (child is MenuButton):
			array.append(child)
		recursive_append_menu_buttons(child, array)

func update_contents():
	var type = event["Type"]
	
	for idx in range(0, ev_structure.size()-1):
		fields[idx].text = event[ev_structure[idx]]
	ev_excl.pressed = event["Exclusive"]

	for idx in range(1, ev_structure.size()-1):
		var button = fields[idx]
		var setting = ev_structure[idx]
		populate(button, Resources.find_restricted_choices(type, setting))

func populate(button : MenuButton, choices : Array):
	var popup = button.get_popup()
	popup.clear()
	popup.raise()
	for option in choices:
		popup.add_item(option)

func change_event(value, setting, signaler):
	if (value == null):
		value = signaler.text
	if (signaler is MenuButton):
		value = signaler.get_popup().get_item_text(value) # Treat value as a popup index
	var adjusted_value = Resources.edit_event(event, setting, value)
	if (not signaler is CheckBox and not signaler is CheckButton):
		signaler.text = adjusted_value
	else:
		signaler.pressed = adjusted_value
	update_contents()

func move_up():
	index -= 1
	Resources.move_event(index, event)

func move_down():
	index += 1
	Resources.move_event(index, event)

func delete():
	Resources.remove_event(event)

func list_update(filter = null):
	if (filter == null):
		populate(ev_oEIDs, Resources.find_restricted_choices(event["Type"], "OutEventIDs"))
	elif (filter == "" or filter in event["EvID"]):
		print(filter)
		emit_signal("unfilter")
	else:
		emit_signal("filter")
