extends Spatial
class_name MovableCamera

onready var camera = $Camera

func set_as_current(v :bool):
	visible = v
