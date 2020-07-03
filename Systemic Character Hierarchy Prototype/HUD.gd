class_name HUD

extends Control

var resources : Resources

onready var name_label = get_node("Name/NameLabel")
onready var id_label = get_node("Name/IDLabel")
onready var role_label = get_node("Role/RoleLabel")
onready var rank_label = get_node("Role/RankLabel")

onready var velocity_label = get_node("Player Velocity/Label")

onready var target_panel = get_node("Target")
onready var target_role = get_node("Target/Role")
onready var target_rank = get_node("Target/Rank")
onready var op_container = get_node("Target/Options/OpContainer")
onready var op_buttons = op_container.get_children()

onready var edit_panel = get_node("Edit")
#onready var edit_rules = get_node("Edit/Rules")
onready var event_editor : EventEditor = get_node("Edit/EventEditor")

signal swap_roles
signal swap_ranks
signal change_events

var player_actor
var target_actor
var last_ray_event : RayCastEvent

func _ready():
	edit_panel.visible = false
	target_panel.visible = false
	print("HUD Ready")
	for button in op_buttons:
		button.disabled = true
	op_buttons[0].grab_focus()

func initialize():
	event_editor.update_item_list(resources)

func set_player_actor(actor):
	player_actor = actor
	update_player_hud()

func update_hud(target_object=null):
	update_player_hud()
	update_target_hud(target_object)

func update_player_hud():
	name_label.text = player_actor.char_name
	id_label.text = "[ " + player_actor.char_id + " ]"
	role_label.text = player_actor.role
	var ranks = player_actor.ranks
	rank_label.text = "\n%d   |   %d   |    %d   " % [ranks["Crime"], ranks["Law"], ranks["Politics"]]

func set_velocity_label(velocity):
	velocity_label.text = "(%8d %8d %8d        )" % [velocity.x, abs(velocity.y), velocity.z]

func set_ray_event(ray_event):
	last_ray_event = ray_event

# Updated when the player looks at an object, or when that object is changed in some way.
func update_target_hud(target_object =null):
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
		var ranks = target_actor.ranks
		target_rank.text = "%d / %d / %d" % [ranks["Crime"], ranks["Law"], ranks["Politics"]]
	else:
		target_actor = null
		target_panel.visible = false
		for button in op_buttons:
			button.disabled = true

#Signal Methods
func press():
	var game_event = GameEvent.new()
	game_event.presser = player_actor
	if (last_ray_event != null):
		game_event.press_normal = last_ray_event.collision_normal
		game_event.press_point = last_ray_event.collision_point
		last_ray_event.free()
	target_actor.press(game_event)

func swap_roles():
	emit_signal("swap_roles", target_actor)
	update_hud(target_actor)

func swap_ranks():
	emit_signal("swap_ranks", target_actor)
	update_hud(target_actor)

func change_events():
	emit_signal("change_events")
	edit_panel.visible = !edit_panel.visible
	if (edit_panel.visible):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	event_editor.update_item_list(resources)
	op_buttons[3].grab_focus()
	update_hud(target_actor)
