#class_name ItemWindow

extends Control

@export var item_template:PackedScene

@onready var item_container = $VBoxContainer/ScrollContainer/VBoxContainer
#onready var test_menu_button = $MenuButton

signal closed

#var resources : Resources
#var events : Array
var item_count : int

func _ready():
	clear_item_list()
#	update_item_list()
#	populate_menu_button(test_menu_button)

# Fully re-loads the item list.
#func update_item_list(res = null):
#	item_count = item_container.get_child_count()
#	if (res != null):
#		resources = res
#		events = res.event_settings
#	var index = 0
#	for event in events:
#		add_item(index, event)
#		index += 1

func clear_item_list():
	for child in item_container.get_children():
		item_container.remove_child(child)
		child.queue_free()
	item_count = 0

# Used whenever an item is added to the events list.
func add_item(index, signal_info : Array = []):#, event):
	var last_index = item_count-1#events.size()-1
	print(str(index) + "  /  " + str(last_index))
	var item = item_template.instantiate()
	item_container.add_child(item)
	item.update_position(last_index, index)
	
	item.moved_up.connect(move_item_up)
	item.moved_down.connect(move_item_down)
	item.deleted.connect(delete_item)
#	if (signal_info.size() != 0):
#	item.connect("id_entered",Callable(self,"change_event_id").bind(signal_info))#[event, item.ev_name])
#	else:
#		item.connect("id_entered",Callable(self,"change_event_id"))
	
	return item
#	update_item(item, event)

# Fully reloads the given item.
#func update_item_contents(item):#, event):
#	pass
#	item.ev_name.text = event["EvID"]
#	item.ev_type.text = event["Type"]
#	item.ev_role.text = event["Role"]
#	item.ev_anim.text = event["Animation"]
#	item.ev_fx.text = event["Effects"]
#	item.ev_iCIDs.text = event["InCharIDs"]
#	item.ev_oEIDs.text = event["OutEventIDs"]

#	populate_menu_button(item, item.ev_type, event["Type"], event["EvID"], "Type")
#	populate_menu_button(item, item.ev_role, event["Type"], event["EvID"], "Role")
#	populate_menu_button(item, item.ev_anim, event["Type"], event["EvID"], "Animation")
#	populate_menu_button(item, item.ev_fx, event["Type"], event["EvID"], "Effects")
#	populate_menu_button(item, item.ev_iCIDs, event["Type"], event["EvID"], "InCharIDs")
#	populate_menu_button(item, item.ev_oEIDs, event["Type"], event["EvID"], "OutEventIDs")

# Clears and Repopulates the given popup.
#func populate_menu_button(button, choices = null, signal_info : Array = []):#item, button, type, event_id, setting):
#	var popup = button.get_popup()
#	if (popup.is_connected("index_pressed",Callable(self,"change_item"))):
#		popup.disconnect("index_pressed",Callable(self,"change_item"))
#	popup.connect("index_pressed",Callable(self,"change_item").bind(signal_info))
#	popup.clear()
#	popup.raise()
##	if (choices == null):
##		choices = resources.find_restricted_choices(type, setting)
#	if (choices != null):
#		for option in choices:
#			popup.add_item(option)

# Changes an event's id and updates the given text field.
#func change_event_id(new_id, event, ev_name):
#	resources.edit_event_id(new_id, event)
#	ev_name.text = event["EvID"]

# Change the given item / edit the corresponding event.
#func change_menu_button(button, index):#, item, button):#, event_id, setting):
##	print(event_id)
#	var new_value = button.get_popup().get_item_text(index)
#	button.text = new_value
#	resources.edit_event_by_id(event_id, setting, new_value)
	#update_item_list()
	
#	var event = resources.get_event_by_id(event_id)
#	update_item(item)#, event)
	#populate_menu_button(button, event["Type"], event_id, setting)

# Shifts the corresponding item up one.
func move_item_up(item):
	var index = item.index
#	var event = events[index]
	var last_index = item_count-1#events.size()-1
#	events.erase(event)
#	events.insert(index-1, event)
	item_container.get_child(index).update_position(last_index, index-1)
	item_container.get_child(index-1).update_position(last_index, index)#events.size(), index-1)
	item_container.move_child(item, item.get_position_in_parent()-1)

# Shifts the corresponding item down one.
func move_item_down(item):
	var index = item.index
#	var event = events[index]
	var last_index = item_count-1#events.size()-1
#	events.erase(event)
#	events.insert(index+1, event)
	item_container.move_child(item, item.get_position_in_parent()+1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(last_index, index+1)

# Used for deleting items at runtime.
func delete_item(item):
	var index = item.index
#	events.remove(index)
	item_container.remove_child(item)
	item.queue_free()
	item_count -= 1
	var last_index = item_count-1#events.size()-1
	var idx : int = 0#last_index - (index-1)
	for itm in item_container.get_children():
		itm.update_position(last_index, idx)
		idx += 1

# Used for adding items at runtime.
func add_new_item(id = null):
#	var event = resources.empty_event(id)
#	resources.add_event(event)
	item_count += 1
	var last_index = item_count-1#events.size()-1
	add_item(last_index)#, event)
	if (item_count > 1):
		item_container.get_child(last_index-1).update_position(last_index)

# Close the edit window.
func close():
	closed.emit()
