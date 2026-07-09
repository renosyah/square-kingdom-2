extends CPUParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(25),"timeout")
	queue_free()
