extends Spatial

onready var _fire = $fire
onready var visibility_notifier = $VisibilityNotifier

var is_burning = false setget _set_is_burning

func _set_is_burning(val :bool):
	is_burning = val
	_fire.emitting = is_burning
		
func _ready():
	visible = visibility_notifier.is_on_screen()
	yield(get_tree().create_timer(15),"timeout")
	queue_free()

func _on_VisibilityNotifier_camera_entered(camera):
	visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	visible = false
