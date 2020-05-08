extends Node

onready var actors = get_node("Actors").get_children()
onready var camera = get_node("Camera")
onready var hud = get_node("HUD")
var player_actor

func _ready():
	set_rand_target_actor()

func _input(event):
	if event.is_action_pressed("reroll"):
		set_rand_target_actor()
	if event.is_action_pressed("quit"):
		get_tree().quit()

func set_rand_target_actor():
	print (actors)
	if player_actor != null:
		player_actor.is_controlled = false
		player_actor.velocity = Vector3()
		player_actor.disconnect("target_found", self, "update_target_hud")
		player_actor.disconnect("target_lost", self, "update_target_hud")
		
	randomize()
# warning-ignore:return_value_discarded
	rand_seed(randi())
	var rand_index = randi()%actors.size()
	if actors[rand_index] == player_actor:
		if rand_index != 0:
			rand_index -= 1
		else:
			rand_index += 1
	player_actor = actors[rand_index]
		
	player_actor.is_controlled = true
	#player_actor.connect("target_found", self, "update_target_hud")
	#player_actor.connect("target_lost", self, "update_target_hud")
	camera.set_target_actor(player_actor)
	camera.connect("target_found", self, "update_target_hud")
	camera.connect("target_lost", self, "update_target_hud")
	hud.set_player_actor(player_actor)

func set_actor_role(new_role, actor=player_actor):
	actor.role = new_role
	#hud.update_hud()

func set_actor_ranks(rank_law, rank_politics, rank_crime, actor=player_actor):
	actor.ranks = {"Law":rank_law, "Politics":rank_politics, "Crime":rank_crime}
	#hud.update_hud()

# Used when the player looks at an object.
func update_target_hud(target_actor=null):
	hud.update_target_hud(target_actor)

#Should be signaled by the HUD object (or by other relevant means).
func swap_roles(actor1, actor2=player_actor):
	var role1 = actor1.role
	var role2 = actor2.role
	set_actor_role(role2, actor1)
	set_actor_role(role1, actor2)

func swap_ranks(actor1, actor2=player_actor):
	var ranks1 = actor1.ranks
	var ranks2 = actor2.ranks
	set_actor_ranks(ranks2["Law"], ranks2["Politics"], ranks2["Crime"], actor1)
	set_actor_ranks(ranks1["Law"], ranks1["Politics"], ranks1["Crime"], actor2)
