class_name EventEditor

extends Control

export (PackedScene) var event_editor_item

onready var item_container = $VBoxContainer/ScrollContainer/VBoxContainer

signal close

var resources : Resources
var events : Array

func update_item_list(res = null):
	for child in item_container.get_children():
		child.free()
	if (res != null):
		resources = res
		events = res.event_settings
	var index = 0
	var last_index = events.size()-1
	for event in events:
		var item : EventEditorItem = event_editor_item.instance()
		item_container.add_child(item)
		item.update_position(last_index, index)
		index += 1
		item.connect("move_up", self, "move_item_up")
		item.connect("move_down", self, "move_item_down")
		item.connect("delete", self, "delete_item")
		update_item(item, event)

func update_item(item, event):
		
	item.ev_name.text = event["EvID"]
	item.ev_type.text = event["Type"]
	item.ev_role.text = event["Role"]
	item.ev_anim.text = event["Animation"]
	item.ev_fx.text = event["Effects"]

	populate_menu_button(item, item.ev_type, event["Type"], event["EvID"], "Type")
	populate_menu_button(item, item.ev_role, event["Type"], event["EvID"], "Role")
	populate_menu_button(item, item.ev_anim, event["Type"], event["EvID"], "Animation")
	populate_menu_button(item, item.ev_fx, event["Type"], event["EvID"], "Effects")

func populate_menu_button(item, button, type, event_id, setting):
	var popup = button.get_popup()
	if (popup.is_connected("index_pressed", self, "change_item")):
		popup.disconnect("index_pressed", self, "change_item")
	popup.connect("index_pressed", self, "change_item", [item, button, event_id, setting])
	popup.clear()
	for option in resources.find_restricted_choices(type, setting):
		popup.add_item(option)

func change_item(index, item, button, event_id, setting):
	var new_value = button.get_popup().get_item_text(index)
	button.text = new_value
	resources.edit_event_by_id(event_id, setting, new_value)
	#update_item_list()
	
	var event = resources.get_event_by_id(event_id)
	update_item(item, event)
	#populate_menu_button(button, event["Type"], event_id, setting)

func move_item_up(item):
	var index = item.index
	var event = events[index]
	var last_index = events.size()-1
	events.erase(event)
	events.insert(index-1, event)
	item_container.move_child(item, item.get_position_in_parent()-1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(events.size(), index-1)

func move_item_down(item):
	var index = item.index
	var event = events[index]
	var last_index = events.size()-1
	events.erase(event)
	events.insert(index+1, event)
	item_container.move_child(item, item.get_position_in_parent()+1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(last_index, index+1)

func delete_item(item):
	var index = item.index
	events.remove(index)
	item.free()
	var last_index = events.size()-1
	if (last_index >= index):
		item_container.get_child(index).update_position(last_index, index)
	if (0 <= index-1):
		item_container.get_child(index-1).update_position(last_index, index-1)

func close():
	emit_signal("close")
