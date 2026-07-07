extends Node

var damage :int
var duration :float
var by :NodePath

onready var timer = $overtime
onready var timeout = $timeout
var _squad :BaseSquad

func _ready():
	yield(get_tree(), "idle_frame")
	
	if get_parent() is BaseSquad:
		_squad = get_parent()
		
	timeout.wait_time = duration
	timeout.start()
	timer.start()
	
func _on_overtime_timeout():
	if not is_instance_valid(_squad):
		return
		
	timer.start()
	
	var members :Array = _squad.get_members(true)
	for idx in members.size():
		_squad.take_damage(damage, idx, by)

func _on_timeout_timeout():
	timer.stop()
	queue_free()
