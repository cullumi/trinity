class_name HUD

extends Control

var resources : Resources

@onready var crosshair:Control = %Crosshair

@onready var title:NamePlate = %NamePlate
@onready var mini_map:MiniMapPanel = %MiniMapPanel
@onready var interact:InteractPanel = %InteractPanel
@onready var edit:EditWindow = %Edit

signal roles_swapped
signal ranks_swapped
signal rules_changed
signal events_changed
signal variations_changed

var editor_signals:Array[Signal] = [
	rules_changed, events_changed, variations_changed
]

var player_actor
var player
var target:Interactable : set=set_target
var last_ray_event : RayCastEvent
var velocity:Vector3 :
	set(val): mini_map.velocity = val; velocity = val;
var edit_active:bool = false : set=set_edit_active

func _ready():
	edit_active = false

#func initialize():
	#event_editor.update_item_list(resources)

func set_edit_active(_show:bool):
	edit.active = _show
	crosshair.visible = not _show

func set_target(inter):
	if inter is Actor:
		target = inter.interaction
	if inter is Interactable:
		target = inter

func set_player_actor(actor):
	player_actor = actor
	player = actor.interaction
	update_player_hud()

func update_hud(target_object=null):
	update_player_hud()
	update_target_hud(target_object)

func update_player_hud():
	title.interactable = player
	mini_map.interactable = player

func set_ray_event(ray_event):
	last_ray_event = ray_event

# Updated when the player looks at an object, or when that object is changed in some way.
func update_target_hud(target_object =null):
	target = null if not target_object else target_object
	interact.active = target != null
	interact.interactable = target


# Interactions

func _on_press():
	var game_event = GameEvent.new()
	game_event.presser = player_actor
	if (last_ray_event != null):
		game_event.press_normal = last_ray_event.collision_normal
		game_event.press_point = last_ray_event.collision_point
		last_ray_event.free()
	target.press(game_event)

func _swap_roles():
	roles_swapped.emit(target)
	update_hud(target)

func _swap_ranks():
	ranks_swapped.emit(target)
	update_hud(target)

var OPT_SUB:Dictionary = {
	interact.OPT.RULES:edit.SUB.RULES,
	interact.OPT.EVENTS:edit.SUB.EVENTS,
	interact.OPT.VARIATIONS:edit.SUB.VARIATIONS
}
func _open_editor(idx:int):
	edit.select_window(OPT_SUB[idx])
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
	update_hud(target)
	crosshair.visible = true
