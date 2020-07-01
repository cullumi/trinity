class_name EventEditor

extends Control

export (PackedScene) var event_editor_item

onready var item_container = $VBoxContainer/ScrollContainer/VBoxContainer

signal close

var resources : Resources
var events : Array

# Fully re-loads the item list.
func update_item_list(res = null):
	for child in item_container.get_children():
		child.queue_free()
	if (res != null):
		resources = res
		events = res.event_settings
	var index = 0
	for event in events:
		add_item(index, event)
		index += 1

# Used whenever an item is added to the events list.
func add_item(index, event):
	var last_index = events.size()-1
	
	var item : EventEditorItem = event_editor_item.instance()
	item_container.add_child(item)
	item.update_position(last_index, index)
	
	item.connect("move_up", self, "move_item_up")
	item.connect("move_down", self, "move_item_down")
	item.connect("delete", self, "delete_item")
	item.connect("id_entered", self, "change_event_id", [event, item.ev_name])
	
	update_item(item, event)

# Fully reloads the given item.
func update_item(item, event):
	item.ev_name.text = event["EvID"]
	item.ev_type.text = event["Type"]
	item.ev_role.text = event["Role"]
	item.ev_anim.text = event["Animation"]
	item.ev_fx.text = event["Effects"]
	item.ev_iCIDs.text = event["InCharIDs"]
	item.ev_oEIDs.text = event["OutEventIDs"]
	
	populate_menu_button(item, item.ev_type, event["Type"], event["EvID"], "Type")
	populate_menu_button(item, item.ev_role, event["Type"], event["EvID"], "Role")
	populate_menu_button(item, item.ev_anim, event["Type"], event["EvID"], "Animation")
	populate_menu_button(item, item.ev_fx, event["Type"], event["EvID"], "Effects")
	populate_menu_button(item, item.ev_iCIDs, event["Type"], event["EvID"], "InCharIDs")
	populate_menu_button(item, item.ev_oEIDs, event["Type"], event["EvID"], "OutEventIDs")

# Clears and Repopulates the given popup.
func populate_menu_button(item, button, type, event_id, setting, choices = null):
	var popup = button.get_popup()
	if (popup.is_connected("index_pressed", self, "change_item")):
		popup.disconnect("index_pressed", self, "change_item")
	popup.connect("index_pressed", self, "change_item", [item, button, event_id, setting])
	popup.clear()
	popup.raise()
	if (choices == null):
		choices = resources.find_restricted_choices(type, setting)
	for option in choices:
		popup.add_item(option)

# Changes an event's id and updates the given text field.
func change_event_id(new_id, event, ev_name):
	resources.edit_event_id(new_id, event)
	ev_name.text = event["EvID"]

func change_item(index, item, button, event_id, setting):
	print(event_id)
	var new_value = button.get_popup().get_item_text(index)
	button.text = new_value
	resources.edit_event_by_id(event_id, setting, new_value)
	#update_item_list()
	
	var event = resources.get_event_by_id(event_id)
	update_item(item, event)
	#populate_menu_button(button, event["Type"], event_id, setting)

# Shifts the corresponding item up one.
func move_item_up(item):
	var index = item.index
	var event = events[index]
	var last_index = events.size()-1
	events.erase(event)
	events.insert(index-1, event)
	item_container.move_child(item, item.get_position_in_parent()-1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(events.size(), index-1)

# Shifts the corresponding item down one.
func move_item_down(item):
	var index = item.index
	var event = events[index]
	var last_index = events.size()-1
	events.erase(event)
	events.insert(index+1, event)
	item_container.move_child(item, item.get_position_in_parent()+1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(last_index, index+1)

# Used for deleting items at runtime.
func delete_item(item):
	var index = item.index
	events.remove(index)
	item.queue_free()
	
	var last_index = events.size()-1
	var idx : int = -1
	for itm in item_container.get_children():
		itm.update_position(last_index, idx)
		idx = idx + 1

# Used for adding items at runtime.
func add_new_item(id = null):
	var event = resources.empty_event(id)
	resources.add_event(event)
	var last_index = events.size()-1
	add_item(last_index, event)

func close():
	emit_signal("close")
