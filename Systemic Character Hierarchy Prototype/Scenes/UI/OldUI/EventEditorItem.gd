#class_name EventEditorItem

extends Control

@onready var ev_name : LineEdit = $"Top Row/EvID"
@onready var ev_type : MenuButton = $"Top Row/Type"
@onready var ev_role : MenuButton = $"Top Row/Role"
@onready var ev_anim : MenuButton = $"Top Row/Animation"
@onready var ev_fx : MenuButton = $"Top Row/Effects"
@onready var ev_iCIDs : MenuButton = $"Bottom Row/InCharIDs"
@onready var ev_oEIDs : MenuButton = $"Bottom Row/OutEventIDs"
@onready var up = $"Top Row/MoveUp"
@onready var down = $"Top Row/MoveDown"
@onready var del = $"Top Row/Delete"

var index
var id_text

signal moved_up
signal moved_down
signal deleted
signal id_entered

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
	moved_up.emit(self)

func move_down():
	moved_down.emit(self)

func delete():
	deleted.emit(self)

func id_field_entered(new_text):
	id_text = new_text
	id_entered.emit(id_text)

func id_field_focus_lost():
	if (id_text != ev_name.text):
		id_text = ev_name.text
		id_entered.emit(id_text)
