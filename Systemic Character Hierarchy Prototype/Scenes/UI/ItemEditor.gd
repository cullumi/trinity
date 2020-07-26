class_name ItemEditor

extends Control

# For keeping track of menu buttons in the 'fields' array
func recursive_append_menu_buttons(node:Node, array:Array):
	for child in node.get_children():
		if (child is MenuButton):
			array.append(child)
		recursive_append_menu_buttons(child, array)

# For populating menu button popups
func populate(button : MenuButton, choices : Array):
	var popup = button.get_popup()
	popup.clear()
	popup.raise()
	for option in choices:
		popup.add_item(option)

# Placeholder-- Used for Applying Filters to the Editor
func list_update(filters=null):
	pass
