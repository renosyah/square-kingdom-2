extends CPUParticles

onready var visibility_notifier = $VisibilityNotifier

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = visibility_notifier.is_on_screen()
	yield(get_tree().create_timer(25),"timeout")
	queue_free()

func _on_VisibilityNotifier_camera_entered(camera):
	visible = true

func _on_VisibilityNotifier_camera_exited(camera):
	visible = false
