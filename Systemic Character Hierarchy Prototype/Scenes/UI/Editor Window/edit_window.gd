extends PanelContainer

class_name EditWindow

@onready var rules = null #%Rules
@onready var events : ItemWindow = %Events
@onready var variations : ItemWindow = %Variations
@onready var windows:Array[ItemWindow] = [
	rules, events, variations
]

signal closed(idx:int)

enum SUB {RULES, EVENTS, VARIATIONS}

var active:bool = true : set=set_active
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

func select_window(idx:int, interactable:Interactable=null):
	var window:ItemWindow = windows[idx]
	if window:
		active = true
		set_window(idx)
		if not window.has_been_initialized:
			window.initialize()
		window.reset_filters(interactable)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func deselect_window():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	active = false
	closed.emit(cur_window)
