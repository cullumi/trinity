extends Control

class_name MiniMapPanel

@onready var role_label = %RoleLabel
@onready var rank_label = %RankLabel
@onready var velocity_label = %VelocityLabel

var interactable:Interactable : set=set_interactable
var velocity:Vector3 : set=set_velocity

func set_interactable(inter:Interactable):
	role_label.text = inter.role
	var ranks = inter.ranks
	rank_label.text = "\n%d   |   %d   |    %d   " % [ranks["Crime"], ranks["Law"], ranks["Politics"]]

func set_velocity(velocity:Vector3):
	velocity_label.text = "(%8d %8d %8d        )" % [velocity.x, abs(velocity.y), velocity.z]
