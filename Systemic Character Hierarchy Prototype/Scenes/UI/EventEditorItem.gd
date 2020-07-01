class_name EventEditorItem

extends HBoxContainer

onready var ev_name = $Name
onready var ev_type : MenuButton = $Type
onready var ev_role : MenuButton = $Role
onready var ev_anim : MenuButton = $Animation
onready var ev_fx : MenuButton = $Effects
onready var up = $MoveUp
onready var down = $MoveDown
onready var del = $Delete

var index

signal move_up
signal move_down
signal delete

func update_position(last_index, new_index = null):
	if (new_index != null):
		index = new_index
	if (index == 0):
		up.disabled = true
	else:
		up.disabled = false
	if (index == last_index):
		down.disabled = true
	else:
		down.disabled = false

func move_up():
	emit_signal("move_up", self)

func move_down():
	emit_signal("move_down", self)

func delete():
	emit_signal("delete", self)
