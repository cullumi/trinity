extends PanelContainer

class_name EditWindow

@onready var rules = null #%Edit/M/Rules
@onready var events : ItemWindow = %Edit/M/Events
@onready var variations : ItemWindow = %Edit/M/Variations

signal editor_changed(idx:int)

enum SUB {RULES, EVENTS, VARIATIONS}
var windows:Array[ItemWindow] = [
	rules, events, variations
]

var active:bool = true : set=set_active
var interactable:Interactable
var cur_window:int : set=set_window

func set_active(_active):
	active = _active
	visible = _active

func set_window(idx:int):
	cur_window = idx
	for w in range(windows.size()):
		var window:ItemWindow = windows[w]
		if window:
			window.visible = w == idx

func select_window(idx:int):
	print("Select Window")
	var window:ItemWindow = windows[idx]
	prints(idx, "->", window)
	if window:
		print("Found Window")
		active = true
		set_window(idx)
		if not window.has_been_initialized:
			window.initialize()
		var filters = Resources.construct_event_filters_from_target(interactable)
		window.reset_filters(filters)
		print("Confining?")
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		editor_changed.emit(idx)

func deselect_window():
	print("Deselect Window")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	editor_changed.emit(cur_window)
