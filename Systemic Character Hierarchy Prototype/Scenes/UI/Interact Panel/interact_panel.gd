extends PanelContainer

class_name InteractPanel

@onready var role_label:Label = %TargetRole
@onready var rank_label:Label = %TargetRank
@onready var op_container:Control = %TargetOptions
@onready var op_buttons:Array[Node] = op_container.get_children()

signal pressed
signal swapped_roles
signal swapped_ranks
signal opened_editor(idx)

enum OPT {PRESS, SWAP_ROLES, SWAP_RANKS, EVENTS, VARIATIONS, RULES}
var signals:Array[Signal] = [pressed, swapped_roles, swapped_ranks, opened_editor]

var active:bool = true : set=set_active
var interactable:Interactable : set=set_interactable

func _ready():
	for b in range(op_buttons.size()):
		var button = op_buttons[b]
		button.pressed.connect(_on_button_pressed.bind(b))

func _on_button_pressed(idx:int):
	if idx >= signals.size()-1:
		signals.back().emit(idx)
	else:
		signals[idx].emit()

func set_active(_active:bool):
	active = _active
	visible = _active
	for button in op_buttons:
		button.disabled = not _active
	if _active:
		set_focused(0)

func set_interactable(inter:Interactable):
	interactable = inter
	if interactable:
		role_label.text = inter.role
		var ranks = inter.ranks
		rank_label.text = "%d / %d / %d" % [ranks["Crime"], ranks["Law"], ranks["Politics"]]
	else:
		active = false

func set_focused(idx:int=0):
	op_buttons[idx].grab_focus()
