class_name EventItemEditor

extends Control

onready var ev_id = $"Top Row/EvID"
onready var ev_type = $"Top Row/Type"
onready var ev_role = $"Top Row/Role"
onready var ev_anim = $"Top Row/Animation"
onready var ev_fx = $"Top Row/Effects"
onready var ev_iCIDs = $"Bottom Row/InCharIDs"
onready var ev_oEIDs = $"Bottom Row/OutEventIDs"
onready var events = Resources.event_settings

var fields = []
var ev_structure = Resources.event_structure
var event
var index
var id

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
		for idx in range(1, ev_structure.size()):
			var popup = fields[idx].get_popup()
			var signal_info = [ev_structure[idx], fields[idx]]
			popup.connect("index_pressed", self, "change_event", signal_info)
	
		update_contents()
#	ev_type.get_popup().connect("index_pressed", self, "change_event", ["Type",ev_type])
#	ev_role.get_popup().connect("index_pressed", self, "change_event", ["Role",ev_role])
#	ev_anim.get_popup().connect("index_pressed", self, "change_event", ["Animation",ev_anim])
#	ev_fx.get_popup().connect("index_pressed", self, "change_event", ["Effects",ev_fx])
#	ev_iCIDs.get_popup().connect("index_pressed", self, "change_event", ["InCharIDs",ev_iCIDs])
#	ev_oEIDs.get_popup().connect("index_pressed", self, "change_event", ["OutEventIDs",ev_oEIDs])

func recursive_append_menu_buttons(node:Node, array:Array):
	for child in node.get_children():
		if (child is MenuButton):
			array.append(child)
		recursive_append_menu_buttons(child, array)

func update_contents():
	var type = event["Type"]
	
	for idx in range(0, ev_structure.size()):
		fields[idx].text = event[ev_structure[idx]]

	for idx in range(1, ev_structure.size()):
		var button = fields[idx]
		var setting = ev_structure[idx]
		populate(button, Resources.find_restricted_choices(type, setting))

func populate(button : MenuButton, choices : Array):
	var popup = button.get_popup()
	popup.clear()
	popup.raise()
	for option in choices:
		popup.add_item(option)

func change_event(new_value, setting, signaler):
	if (new_value == null):
		new_value = signaler.text
	if (signaler is MenuButton):
		new_value = signaler.get_popup().get_item_text(new_value) # Treat value as a popup index
	var adjusted_value = Resources.edit_event(event, setting, new_value)
	signaler.text = adjusted_value
	update_contents()

func move_up():
	index -= 1
#	print(Resources.event_ids)
#	Resources.event_ids.remove(index)
#	Resources.event_ids.insert(index-1, event["EvID"])
#	print(Resources.event_ids)
	Resources.move_event(index, event)
	

func move_down():
	index += 1
	Resources.move_event(index, event)

func delete():
	Resources.remove_event(event)

func list_update():
	populate(ev_oEIDs, Resources.find_restricted_choices(event["Type"], "OutEventIDs"))
	print(Resources.event_ids)
	#update_contents()
