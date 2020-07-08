class_name ItemWindowItem

extends Control

export (PackedScene) var content_template

onready var content_pos #= $ContentPos
onready var up = $SideBar/UpDelete/MoveUp
onready var down = $SideBar/MoveDown
onready var del = $SideBar/UpDelete/Delete

var index
var content

signal move_up
signal move_down
signal delete

func _ready():
	if (content_template != null):
		add_content(content_template)

func add_content(template : PackedScene, id = null):#node : Node = null):
	if (content_pos == null):
		content_pos = get_node("ContentPos")
	content = template.instance()
	content.index = index
	content.id = id
	content_pos.add_child(content)
	content.connect("apply_filter", self, "apply_filter")

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
	content.move_up()
	emit_signal("move_up", self)

func move_down():
	content.move_down()
	emit_signal("move_down", self)

func delete():
	content.delete()
	emit_signal("delete", self)

func list_update(filter = null):
	content.list_update(filter)

func apply_filter(filtered : bool):
	if (filtered):
		visible = false
	else:
		visible = true
