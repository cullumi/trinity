class_name Filter

extends Object

var string_value : String
var type_value : String
var boolean_value : bool
var filtered_keys : Dictionary
var is_or_filter : bool
var include_derivatives : bool
var inclusive : bool
var enabled : bool

func _init(str_val="",bool_val=false,fltr_keys=[],is_or=false,inc_derivs=false,inc=true,type_val="",enbld=true):
	string_value = str_val
	boolean_value = bool_val
	filtered_keys = {}
	for key in fltr_keys:
		filtered_keys[key] = true
	is_or_filter = is_or
	include_derivatives = inc_derivs
	inclusive = inc
	type_value = type_val
	enabled = enbld
