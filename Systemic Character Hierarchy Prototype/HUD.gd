extends Control

class_name HUD

var resources : Resources

@onready var crosshair:Control = %Crosshair

@onready var title:NamePlate = %NamePlate
@onready var mini_map:MiniMapPanel = %MiniMapPanel
@onready var interact:InteractPanel = %InteractPanel
@onready var edit:EditWindow = %Edit

signal roles_swapped
signal ranks_swapped(inter1:Interactable, inter2:Interactable)
signal rules_changed
signal events_changed
signal variations_changed

var editor_signals:Array[Signal] = [
	rules_changed, events_changed, variations_changed
]

var p_actor:Actor : set=set_p_actor
var player:Interactable : set=set_player
var target:Interactable : set=set_target
var last_ray_event : RayCastEvent
var velocity:Vector3 : set=set_velocity
var edit_active:bool = false : set=set_edit_active

func _ready():
	edit_active = false
	target = target

#func initialize():
	#event_editor.update_item_list(resources)

func get_crosshair_location() -> Vector2:
	var viewport:Viewport = get_viewport()
	var control_rect:Rect2 = crosshair.get_rect()
	var control_pos:Vector2 = crosshair.global_position
	var viewport_pos:Vector2 = viewport.get_visible_rect().position
	
	var screen_pos = control_pos - viewport_pos + control_rect.size / 2
	return screen_pos

func set_edit_active(_show:bool):
	edit.active = _show
	crosshair.visible = not _show

func inter_convert(inter):
	return inter if not (inter is Actor) else inter.interactor

func set_velocity(vel:Vector3):
	velocity = vel
	mini_map.velocity = vel

func set_target(inter):
	inter = inter_convert(inter)
	target = inter
	interact.active = target != null
	if target:
		print("Target: ", target)
		interact.interactable = target

func set_p_actor(actor:Actor):
	p_actor = actor
	player = inter_convert(actor)

var velocity_signal
func set_player(_player:Interactable):
	player = _player
	prints("Set player?", player)
	if velocity_signal:
		velocity_signal.disconnect(set_velocity)
		velocity_signal = null
	if player:
		if p_actor:
			velocity_signal = p_actor.velocity_changed
			p_actor.velocity_changed.connect(set_velocity)
		title.interactable = player
		mini_map.interactable = player

func set_ray_event(ray_event):
	last_ray_event = ray_event

# Interactions

func _on_press():
	var game_event = GameEvent.new()
	game_event.presser = player
	if (last_ray_event != null):
		game_event.press_normal = last_ray_event.collision_normal
		game_event.press_point = last_ray_event.collision_point
		last_ray_event.free()
	target.press(game_event)

func _swap_roles():
	roles_swapped.emit(target, player)
	target = target
	player = player

func _swap_ranks():
	prints("Player?", player)
	ranks_swapped.emit(target, player)
	target = target
	player = player

var OPT_SUB:Dictionary = {
	interact.OPT.RULES:edit.SUB.RULES,
	interact.OPT.EVENTS:edit.SUB.EVENTS,
	interact.OPT.VARIATIONS:edit.SUB.VARIATIONS
}
func _open_editor(idx:int):
	edit.select_window(OPT_SUB[idx], target)
	crosshair.visible = false
	interact.active = false


# Editing

var SUB_OPT:Dictionary = {
	edit.SUB.RULES:interact.OPT.RULES,
	edit.SUB.EVENTS:interact.OPT.EVENTS,
	edit.SUB.VARIATIONS:interact.OPT.VARIATIONS,
}
func _on_editor_closed(idx:int):
	interact.set_focused(SUB_OPT[idx])
	target = target
	crosshair.visible = true
