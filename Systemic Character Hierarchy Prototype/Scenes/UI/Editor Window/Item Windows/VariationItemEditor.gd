class_name VariationItemEditor

extends ItemEditor

@onready var vari_tex = $"Top Row/Tex"
@onready var vari_fx = $"Top Row/Effects"
@onready var variations = Resources.variation_settings

signal apply_filter

var fields = []
var vari_structure = Resources.variation_structure
var variation
var index
var id

func _ready():
	initialize()

func initialize():
	if (index != null):
		# Find the event tied to this variation editor
		if (index < variations.size() and index >= 0):
			variation = variations[index]
		else:
			variation = Resources.new_variation()
			Resources.add_variation(variation)
		
		# Initialization of individual fields and buttons
		recursive_append_menu_buttons(self, fields)
		for idx in range(0, vari_structure.size()):
			var popup = fields[idx].get_popup()
			var signal_info = [vari_structure[idx], fields[idx]]
			popup.index_pressed.connect(change_variation.bind(signal_info))
	
		update_contents()

## For keeping track of menu buttons in the 'fields' array
#func recursive_append_menu_buttons(node:Node, array:Array):
#	for child in node.get_children():
#		if (child is MenuButton):
#			array.append(child)
#		recursive_append_menu_buttons(child, array)

func update_contents():
	for idx in range(0, vari_structure.size()):
		fields[idx].text = variation[vari_structure[idx]]

	for idx in range(0, vari_structure.size()):
		var button = fields[idx]
		var setting = vari_structure[idx]
		populate(button, Resources.find_choices(setting))

## For populating menu button popups
#func populate(button : MenuButton, choices : Array):
#	var popup = button.get_popup()
#	popup.clear()
#	popup.raise()
#	for option in choices:
#		popup.add_item(option)

# Sends values to Resources for any needed adjustments when editing the variation.
# Updates checkbox and checkbutton values to with those adjustments.
func change_variation(new_value, setting, signaler):
	if (new_value == null):
		new_value = signaler.text
	if (signaler is MenuButton):
		new_value = signaler.get_popup().get_item_text(new_value) # Treat value as a popup index
	var adjusted_value = Resources.edit_variation(variation, setting, new_value)
	signaler.text = adjusted_value
	update_contents()

func move_up():
	index -= 1
	Resources.move_variation(index, variation)

func move_down():
	index += 1
	Resources.move_variation(index, variation)

func delete():
	Resources.remove_variation(variation)

# Applys filters to this item editor
func list_update(filters=null):
	if (filters != null):
		var final_filtered = false
		for filter in filters:
			if (filter.enabled):
				final_filtered = key_filtered(variation, filter)
		apply_filter.emit(final_filtered)

# Determines whether this item editor should be filtered out based on the given filter.
func key_filtered(_variation, filter):
	for key in filter.filtered_keys:
		if (not (filter.string_value in _variation[key])):
			return true
	return false

func construct_filters(inter:Interactable=null):
	return [] if not inter else Resources.construct_variation_filters_from_target(inter)
