extends BaseTile

export var target :NodePath
onready var _target = get_node_or_null(target)

var _v_notifier :VisibilityNotifier

func _ready():
	_v_notifier = VisibilityNotifier.new()
	_v_notifier.aabb = AABB(Vector3.ONE * -0.5, Vector3.ONE)
	_v_notifier.max_distance = 12
	_v_notifier.connect("camera_entered", self, "_on_VisibilityNotifier_camera_entered")
	_v_notifier.connect("camera_exited", self, "_on_VisibilityNotifier_camera_exited")
	add_child(_v_notifier)

func _on_VisibilityNotifier_camera_entered(camera):
	_target.visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	_target.visible = false
