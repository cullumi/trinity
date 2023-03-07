@tool

class_name ItemWindow

extends Control

@export var item_structure:PackedScene
@export var item_content:PackedScene
@export_enum ("Editor", "Events", "Variations") var content_source:String = "Editor" : set = set_content_source
@export var use_filters:bool = false
@export var use_advanced_filters:bool = false

@onready var item_container:BoxContainer = %Items
@onready var title_label:Label = %Title
@onready var filter_selector:BoxContainer = %FilterSelector
signal closed

var item_count : int
var has_been_initialized = false

var last_filter_value
var filters : Array


# SETTERS

func set_content_source(_source):
	if Engine.is_editor_hint():
		if title_label == null and is_inside_tree():
			title_label = get_node("%Title")
		if title_label:
			title_label.text = _source
	content_source = _source


# INITIALIZATION AND UPDATES

func initialize():
	title_label.text = content_source
	
	if Engine.is_editor_hint(): return
	clear_item_list()
	
	if (content_source in Resources.settings_arrays.keys()):
		for index in range(0, Resources.settings_arrays[content_source].size()):
			add_item(index)
		if (use_filters):
			if (not use_advanced_filters):
				filter_selector.initialize(false)
			for key in Resources.structure_arrays[content_source]:
				filter_selector.add_key_item(key)
			filters = [Filter.new("", false, [], false)]
			filter_selector.display(filters[0], 0)
		filter_selector.visible = use_filters
	else:
		filter_selector.visible = false
	
	has_been_initialized = true

func list_update():
	for child in item_container.get_children():
		child.list_update(filters)

func position_update(last_index, start_index):
	var idx = start_index
	for child in item_container.get_children():
		child.update_position(last_index, idx)
		idx += 1


# ITEM ADDITION AND CLEARING

# Clears all items.
func clear_item_list():
	for child in item_container.get_children():
		item_container.remove_child(child)
		child.queue_free()
	item_count = 0

# Used to add an item.
func add_item(index, id = null):
	item_count += 1
	var last_index = item_count-1
	var item:ItemWindowItem = item_structure.instantiate()
	item_container.add_child(item)
	item.update_position(last_index, index)
	if (item_content):
		print("New Item")
		item.add_content(item_content, id)
	
	item.moved_up.connect(move_item_up)
	item.moved_down.connect(move_item_down)
	item.deleted.connect(delete_item)
	
	if (item_count > 1):
		item_container.get_child(last_index-1).update_position(last_index)
		list_update()
	
	return item


# RUNTIME SIGNAL COMMANDS

# Used to add a new item.
func add_new_item(id = null):
	var last_index = item_count
	add_item(last_index, id)

# Used for deleting items at runtime.
func delete_item(item):
	item_container.remove_child(item)
	item.queue_free()
	item_count -= 1
	var last_index = item_count-1
	position_update(last_index, 0)
	list_update()

# Shifts the corresponding item up one.
func move_item_up(item):
	var index = item.index
	var last_index = item_count-1
	item_container.get_child(index).update_position(last_index, index-1)
	item_container.get_child(index-1).update_position(last_index, index)
	item_container.move_child(item, item.get_index()-1)
	list_update()

# Shifts the corresponding item down one.
func move_item_down(item):
	var index = item.index
	var last_index = item_count-1
	item_container.move_child(item, item.get_index()+1)
	item_container.get_child(index).update_position(last_index, index)
	item.update_position(last_index, index+1)
	list_update()

# Close the edit window.
func close():
	closed.emit()


# FILTER FUNCTIONS

func construct_filters(_inter:Interactable=null) -> Array:
	match content_source:
		"Events": return Resources.construct_event_filters_from_target(_inter)
		"Variations": return Resources.construct_variation_filters_from_target(_inter)
		_: return [Filter.new()]

func reset_filters(inter:Interactable=null):
	clear_filters(false)
	var new_filters:Array = construct_filters(inter)
	Resources.append_array(filters, new_filters)
	display_filter(0)

func add_new_filter(str_val="", bool_val=false, fltr_keys=null, is_or=false):
	fltr_keys = fltr_keys if fltr_keys != null else Resources.structure_arrays[content_source]
	var filter : Filter = Filter.new(str_val, bool_val, fltr_keys, is_or)
#	if (content_source in Resources.structure_arrays.keys()):
	filters.append(filter)
	return filters.find(filter)

func filter_changed():
	list_update()

func change_display(idx):
	while (idx >= filters.size()):
		idx -= 1
	filter_selector.display(filters[idx], idx)

func remove_filter(filter, idx):
	filters.erase(filter)
	filter.free()
	if (filters.size() <= 0):
		filters.append(Filter.new("", false, [], false))
	if (idx >= filters.size()):
		idx = filters.size()-1
	filter_selector.display(filters[idx], idx)

func add_filter(idx):
	filters.insert(idx, Filter.new("", false, [], false))
	filter_selector.display(filters[idx], idx)

func clear_filters(safe_clear=true):
	for filter in filters:
		filter.free()
	filters.clear()
	if (safe_clear and filters.size() <= 0):
		filters.append(Filter.new("", false, [], false))
		filter_selector.display(filters[0], 0)

func display_filter(idx=0):
	if not filters.is_empty():
		filter_selector.display(filters[idx], idx)
