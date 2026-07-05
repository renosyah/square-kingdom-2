extends Node

var squad :BaseSquad
var damage :int
var duration :float
var by :NodePath

onready var timer = $overtime

func _ready():
	timer.start()
	
	yield(get_tree().create_timer(duration),"timeout")
	timer.stop()
	queue_free()
	
func _on_overtime_timeout():
	timer.start()
	
	var members :Array = squad.get_members(true)
	for idx in members.size():
		squad.take_damage(damage, idx, by)


