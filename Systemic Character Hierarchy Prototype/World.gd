extends Node

@onready var actors = %Actors.get_children()
@onready var camera:PlayerCamera = %PlayerCamera
@onready var hud = %HUD
@onready var event_handler = %EventHandler
var player:Actor

var last_ray_event = null

func _ready():
	camera.hud = hud
	Resources.update_world()
	print("World Ready")
	set_rand_target_actor()
	camera.target_found.connect(update_target_hud)
	camera.target_lost.connect(update_target_hud)
	#hud.initialize()
	get_tree().call_group("Interactables", "connect_pressed", event_handler, "trigger_press_event")

func _unhandled_input(event):
	if event.is_action_pressed("reroll"):
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
			set_rand_target_actor()
	elif event.is_action_pressed("quit"):
		get_tree().quit()

func set_rand_target_actor():
	if player != null:
		player.is_controlled = false
		player.velocity = Vector3()
		player.avatar.visible = true
		
	randomize()
	# warning-ignore:return_value_discarded
#	rand_from_seed(randi())
	var rand_index = randi()%actors.size()
	if actors[rand_index] == player:
		if rand_index != 0:
			rand_index -= 1
		else:
			rand_index += 1
	player = actors[rand_index]
		
	player.is_controlled = true
	camera.player = player
	prints("Current player:", player)
	hud.p_actor = player

func set_actor_ranks(rank_law, rank_politics, rank_crime, actor=player):
	actor.ranks = {"Crime":rank_crime, "Politics":rank_politics, "Law":rank_law}

func add_ray_event(ray_event):
	hud.set_ray_event(ray_event)

# Used when the player looks at an object.
func update_target_hud(target=null):
	hud.target = target

# Should be signaled by the HUD object (or by other relevant means).
func swap_roles(entity1, entity2=player.entity):
	var role1 = entity1.role
	entity1.role = entity2.role
	entity2.role = role1

func swap_ranks(entity1, entity2=player.entity):
	var ranks1 = entity1.ranks
	entity1.ranks = entity2.ranks
	entity2.ranks = ranks1
