extends Node

var squad :BaseSquad
var damage :int
var duration :float
var by :NodePath

onready var timer = $overtime
onready var timeout = $timeout

func _ready():
	timeout.wait_time = duration
	timeout.start()
	timer.start()
	
func _on_overtime_timeout():
	if not is_instance_valid(squad):
		return
		
	timer.start()
	
	var members :Array = squad.get_members(true)
	for idx in members.size():
		squad.take_damage(damage, idx, by)

func _on_timeout_timeout():
	timer.stop()
	queue_free()
