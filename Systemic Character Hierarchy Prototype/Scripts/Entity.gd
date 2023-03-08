extends Resource

class_name Entity

# Functionality
@export_group("Functionality")
@export_enum("Intble", "Button", "Actor") var type:String = "Intble"
@export_enum("Smooth", "Dusty", "Splashy") var texture:String = "Smooth"

# Identification
@export_group("Identification")
@export var char_name:String = "!%()*^)($^#)"
@export var char_id:String = ""

# Hierarchy
@export_group("Hierarchy")
@export var role:String = "&%8)@#&"
@export var ranks:Dictionary = {"Law":-INF, "Politics":-INF, "Crime":-INF}

var interactor:Interactable
