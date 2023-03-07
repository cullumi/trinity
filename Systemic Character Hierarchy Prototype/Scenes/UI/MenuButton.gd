extends MenuButton

@onready var popup = get_popup()
var checkable_items = true
var hard_initialization = true
var selectable = true

signal item_selected

func _ready():
	if (hard_initialization):
		popup.clear()
	popup.hide_on_checkable_item_selection = false
	popup.index_pressed.connect(item_pressed)

func item_pressed(idx):
	if (popup.is_item_checkable(idx)):
		popup.toggle_item_checked(idx)
		item_selected.emit(popup.is_item_checked(idx), popup.get_item_text(idx))

func add_item(label):
	if (checkable_items):
		popup.add_check_item(label)
	else:
		popup.add_item(label)

# Sets popups corresponding to the keys in the given array as checked in the menu popup.
func display(keys:Array):
	if (checkable_items):
		for idx in range(0, popup.get_item_count()):
			var key_match = false
			for key in keys:
				if (key == popup.get_item_text(idx)):
					popup.set_item_checked(idx, true)
					key_match = true
					break
			if (not key_match):
				popup.set_item_checked(idx, false)
		
