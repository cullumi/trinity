extends PanelContainer

class_name NamePlate

@onready var name_label:Label = %NameLabel
@onready var id_label:Label = %IDLabel

var interactable:Interactable : set=set_interactable

func set_interactable(inter:Interactable):
	interactable = inter
	name_label.text = inter.char_name
	id_label.text = "[ " + inter.char_id + " ]"
