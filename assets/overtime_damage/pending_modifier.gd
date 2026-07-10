extends Node

export var datas :Array
export var remove_modifier :Array = []

func _ready():
	yield(get_tree(), "idle_frame")
	
	var _squad :BaseSquad
	if get_parent() is BaseSquad:
		_squad = get_parent()
		
	if is_instance_valid(_squad):
		_squad.set_modifiers(datas, remove_modifier)
		
	queue_free()
