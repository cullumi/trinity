class_name ItemWindowItem

extends Control

@export var content_template:PackedScene

@onready var content_pos #= $ContentPos
@onready var up = $SideBar/UpDelete/MoveUp
@onready var down = $SideBar/MoveDown
@onready var del = $SideBar/UpDelete/Delete

var index
var content

signal moved_up
signal moved_down
signal deleted

func _ready():
	if (content_template != null):
		add_content(content_template)

func add_content(template : PackedScene, id = null):#node : Node = null):
	if (content_pos == null):
		content_pos = get_node("ContentPos")
	content = template.instantiate()
	content.index = index
	content.id = id
	content_pos.add_child(content)
	content.connect("apply_filter",Callable(self,"apply_filter"))

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
	moved_up.emit(self)

func move_down():
	content.move_down()
	moved_down.emit(self)

func delete():
	content.delete()
	deleted.emit(self)

func list_update(filters = null):
	content.list_update(filters)

func apply_filter(filtered : bool):
	if (filtered):
		visible = false
	else:
		visible = true
