extends Control

@onready var remove_btn = $RemoveButton
@onready var add_btn = $AddButton
@onready var or_check_box = $OrEnabled/OrCheckBox
@onready var enabled_check_box = $OrEnabled/EnabledCheckBox
@onready var text_field = $"Text ChkBxs/TextField"
@onready var chk_bxs = $"Text ChkBxs/ChkBxs"
@onready var bool_check_box = $"Text ChkBxs/ChkBxs/boolCheckBox"
@onready var inc_derivs = $"Text ChkBxs/ChkBxs/derivatives"
@onready var inclusive_cb = $"Text ChkBxs/ChkBxs/inclusive"
@onready var popup_menu = $PopupMenu
@onready var spin_box = $SpinBox
var index = 0
var filter : Filter

signal filter_changed
signal change_display
signal add_filter
signal remove_filter


func initialize(chkbxs=true):
	chk_bxs.visible = chkbxs


func display(fltr:Filter, idx=-1):
	filter = fltr
	or_check_box.button_pressed = filter.is_or_filter
	enabled_check_box.button_pressed = filter.enabled
	text_field.text = filter.string_value
	bool_check_box.button_pressed = filter.boolean_value
	inc_derivs.button_pressed = filter.include_derivatives
	inclusive_cb.button_pressed = filter.inclusive
	popup_menu.display(filter.filtered_keys.keys())
	index = idx
	if (spin_box.value != idx):
		spin_box.value = idx


func add_key_item(key):
	popup_menu.add_item(key)


func _on_OrCheckBox_toggled(button_pressed):
	filter.is_or_filter = button_pressed
	filter_changed.emit()


func _on_EnabledCheckBox_toggled(button_pressed):
	filter.enabled = button_pressed
	filter_changed.emit()


func _on_includeDerivatives_toggled(button_pressed):
	filter.include_derivatives = button_pressed
	filter_changed.emit()


func _on_inclusive_toggled(button_pressed):
	filter.inclusive = button_pressed
	filter_changed.emit()


func _on_TextField_text_changed(new_text):
	filter.string_value = new_text
	emit_signal("filter_changed")


func _on_boolCheckBox_toggled(button_pressed):
	filter.boolean_value = button_pressed
	emit_signal("filter_changed")

func _on_PopupMenu_item_selected(value, key):
	filter.filtered_keys[key] = value
	emit_signal("filter_changed")


func _on_SpinBox_value_changed(value):
	if (value != index):
		emit_signal("change_display", value)


func _on_RemoveButton_pressed():
	emit_signal("remove_filter", filter, index)


func _on_AddButton_pressed():
	emit_signal("add_filter", index+1)
