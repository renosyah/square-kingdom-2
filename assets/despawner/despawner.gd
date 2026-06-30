extends Node

export var target :NodePath
export var timeout :float = 24

onready var _target = get_node_or_null(target)
onready var _timer = $Timer

func _ready():
	_timer.wait_time = timeout
	_timer.start()

func _on_Timer_timeout():
	_target.queue_free()
