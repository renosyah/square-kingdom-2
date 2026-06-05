extends BaseTile

export var target :NodePath
onready var _target = get_node_or_null(target)

func _on_VisibilityNotifier_camera_entered(camera):
	_target.visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	_target.visible = false
