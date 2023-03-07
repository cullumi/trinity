extends Node


signal select_pressed
signal select_released
signal scrolled_down
signal scrolled_up

func _unhandled_input(event):
	# Mouse UI Selection
	if event.is_action_pressed("select"):
		select_pressed.emit()
#		if event is InputEventMouseButton:
#			trigger_input_action("ui_accept", true)
	elif event.is_action_released("select"):
		select_released.emit()
#		if event is InputEventMouseButton:
#			trigger_input_action("ui_accept", false)
	elif event.is_action_pressed("scroll_down"):
		scrolled_down.emit()
		if event is InputEventMouseButton:
			trigger_input_action("ui_focus_next", true)
			trigger_input_action("ui_focus_next", false)
	elif event.is_action_pressed("scroll_up"):
		scrolled_up.emit()
		if event is InputEventMouseButton:
			trigger_input_action("ui_focus_prev", true)
			trigger_input_action("ui_focus_prev", false)
		

# Creates and parses an input action event.
func trigger_input_action(action, pressed):
	var event = InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
