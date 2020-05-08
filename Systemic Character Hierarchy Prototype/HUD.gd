extends Control

onready var role_label = get_node("Role/RoleLabel")
onready var rank_label = get_node("Rank/RankLabel")

onready var velocity_label = get_node("Player Velocity/Label")

onready var target_panel = get_node("Target")
onready var target_role = get_node("Target/Role")
onready var target_rank = get_node("Target/Rank")
onready var op_container = get_node("Target/Options/OpContainer")
onready var op_buttons = op_container.get_children()

signal swap_roles
signal swap_ranks
signal change_rules

var player_actor
var target_actor

func _ready():
	target_panel.visible = false
	for button in op_buttons:
		button.disabled = true
	op_buttons[0].grab_focus()

func set_player_actor(actor):
	player_actor = actor
	role_label.text = player_actor.role
	rank_label.text = PoolStringArray(player_actor.ranks.values()).join(" / ")

func update_hud(target_object=null):
	update_player_hud()
	update_target_hud(target_object)

func update_player_hud():
	role_label.text = player_actor.role
	rank_label.text = PoolStringArray(player_actor.ranks.values()).join(" / ")

func set_velocity_label(velocity):
	velocity_label.text = str(velocity)

# Updated when the player looks at an object, or when that object is changed in some way.
func update_target_hud(target_object=null):
	if target_object != null:
		var target_changed = false
		if (target_actor != target_object):
			target_changed = true
			target_actor = target_object
		if (target_changed):
			target_panel.visible = true
			for button in op_buttons:
				button.disabled = false
			op_buttons[0].grab_focus()
		target_role.text = target_actor.role
		target_rank.text = PoolStringArray(target_actor.ranks.values()).join(" / ")
	else:
		target_actor = null
		target_panel.visible = false
		for button in op_buttons:
			button.disabled = true

#Signal Methods
func swap_roles():
	emit_signal("swap_roles", target_actor)
	update_hud(target_actor)

func swap_ranks():
	emit_signal("swap_ranks", target_actor)
	update_hud(target_actor)

func change_rules():
	emit_signal("change_rules")
	update_hud(target_actor)
