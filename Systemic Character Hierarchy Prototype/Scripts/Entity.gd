extends Resource

class_name Entity

# Functionality
@export_group("Functionality")
@export_enum("Intble", "Button", "Actor") var type:String = "Intble"
@export_enum("Smooth", "Dusty", "Splashy") var texture:String = "Smooth"

# Identification
@export_group("Identification")
@export var char_name:String = "Button"
@export var char_id:String = ""

# Hierarchy
@export_group("Hierarchy")
@export var role:String = "Button"
@export var ranks:Dictionary = {"Law":0, "Politics":0, "Crime":0}

var interactor:Interactable
